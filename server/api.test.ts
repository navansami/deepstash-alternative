import { MongoMemoryServer } from 'mongodb-memory-server';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';

let mongo: MongoMemoryServer;
let app: typeof import('./app.js').app;
let db: typeof import('./db.js');

const today = new Date().toISOString().slice(0, 10);

beforeAll(async () => {
  mongo = await MongoMemoryServer.create({ instance: { launchTimeout: 90_000 } });
  process.env.MONGODB_URI = mongo.getUri();
  process.env.MONGODB_DB = 'kernel_test';
  process.env.JWT_SECRET = 'test-secret-that-is-definitely-long-enough-1234';
  ({ app } = await import('./app.js'));
  db = await import('./db.js');
  const { runSeed } = await import('./seed/index.js');
  await runSeed();
}, 120_000);

afterAll(async () => {
  await db?.closeDb();
  await mongo?.stop();
});

type Json = Record<string, any>;

async function call(method: string, path: string, opts: { token?: string; body?: unknown } = {}) {
  const res = await app.request(`/api${path}`, {
    method,
    headers: {
      'Content-Type': 'application/json',
      ...(opts.token ? { Authorization: `Bearer ${opts.token}` } : {}),
    },
    body: opts.body === undefined ? undefined : JSON.stringify(opts.body),
  });
  return { status: res.status, json: (await res.json()) as Json };
}

let n = 0;
async function register(name = 'Test User') {
  const email = `user${++n}@example.com`;
  const r = await call('POST', '/auth/register', { body: { email, password: 'correct horse', name } });
  expect(r.status).toBe(201);
  return { email, token: r.json.accessToken as string, refresh: r.json.refreshToken as string, id: r.json.user.id as string };
}

async function setRole(email: string, role: 'admin' | 'editor') {
  const { users } = await db.cols();
  await users.updateOne({ email }, { $set: { role } });
}

const lessonBody = {
  title: 'My test lesson',
  summary: 'A summary',
  topic: 'habits',
  body: 'This is a lesson body that is long enough to pass validation, with several words in it.',
  takeaways: ['One'],
  cards: [{ type: 'idea', title: 'Card one', body: 'Body one' }, { type: 'tip', title: 'Card two', body: 'Body two' }],
};

describe('auth', () => {
  it('registers, rejects duplicates and bad input, and never returns the password hash', async () => {
    const u = await register();
    const me = await call('GET', '/me', { token: u.token });
    expect(me.status).toBe(200);
    expect(me.json.user.email).toBe(u.email);
    expect(JSON.stringify(me.json)).not.toContain('passwordHash');

    const dup = await call('POST', '/auth/register', { body: { email: u.email.toUpperCase(), password: 'another one', name: 'X' } });
    expect(dup.status).toBe(409);
    const weak = await call('POST', '/auth/register', { body: { email: 'w@example.com', password: 'short', name: 'X' } });
    expect(weak.status).toBe(400);
    expect(weak.json.error).toMatch(/password/);
  });

  it('logs in, rejects wrong passwords, and locks after repeated failures', async () => {
    const u = await register();
    expect((await call('POST', '/auth/login', { body: { email: u.email, password: 'correct horse' } })).status).toBe(200);
    for (let i = 0; i < 5; i++) {
      expect((await call('POST', '/auth/login', { body: { email: u.email, password: 'wrong' } })).status).toBe(401);
    }
    const locked = await call('POST', '/auth/login', { body: { email: u.email, password: 'correct horse' } });
    expect(locked.status).toBe(429);
  });

  it('rotates refresh tokens and rejects reuse', async () => {
    const u = await register();
    const r1 = await call('POST', '/auth/refresh', { body: { refreshToken: u.refresh } });
    expect(r1.status).toBe(200);
    expect((await call('POST', '/auth/refresh', { body: { refreshToken: u.refresh } })).status).toBe(401);
    await call('POST', '/auth/logout', { body: { refreshToken: r1.json.refreshToken } });
    expect((await call('POST', '/auth/refresh', { body: { refreshToken: r1.json.refreshToken } })).status).toBe(401);
  });

  it('rejects missing and forged tokens', async () => {
    expect((await call('GET', '/me')).status).toBe(401);
    expect((await call('GET', '/me', { token: 'not.a.jwt' })).status).toBe(401);
  });

  it('changes password (old one stops working) and requires it to delete the account', async () => {
    const u = await register();
    const bad = await call('POST', '/me/password', { token: u.token, body: { currentPassword: 'nope', newPassword: 'new password 1' } });
    expect(bad.status).toBe(400);
    const ok = await call('POST', '/me/password', { token: u.token, body: { currentPassword: 'correct horse', newPassword: 'new password 1' } });
    expect(ok.status).toBe(200);
    expect((await call('POST', '/auth/login', { body: { email: u.email, password: 'correct horse' } })).status).toBe(401);
    expect((await call('POST', '/auth/refresh', { body: { refreshToken: u.refresh } })).status).toBe(401);

    expect((await call('DELETE', '/me', { token: ok.json.accessToken, body: { password: 'wrong' } })).status).toBe(400);
    expect((await call('DELETE', '/me', { token: ok.json.accessToken, body: { password: 'new password 1' } })).status).toBe(200);
    expect((await call('GET', '/me', { token: ok.json.accessToken })).status).toBe(401);
  });
});

describe('feed, lessons and progress', () => {
  it('serves a stable daily feed from chosen topics', async () => {
    const u = await register();
    await call('PATCH', '/me', { token: u.token, body: { topics: ['habits', 'money', 'health'] } });
    const f1 = await call('GET', `/feed?date=${today}`, { token: u.token });
    expect(f1.status).toBe(200);
    expect(f1.json.cards.length).toBeGreaterThan(0);
    expect(f1.json.cards.every((c: Json) => ['habits', 'money', 'health'].includes(c.topic))).toBe(true);
    const f2 = await call('GET', `/feed?date=${today}`, { token: u.token });
    expect(f2.json.cards.map((c: Json) => c.id)).toEqual(f1.json.cards.map((c: Json) => c.id));
    expect((await call('GET', '/feed?date=1999-01-01', { token: u.token })).status).toBe(400);
  });

  it('returns full lessons with markdown, takeaways and cards', async () => {
    const u = await register();
    const list = await call('GET', '/lessons?topic=psychology', { token: u.token });
    expect(list.json.lessons.length).toBe(2);
    expect(list.json.lessons[0].body).toBeUndefined();
    const full = await call('GET', '/lessons/deep-work', { token: u.token });
    expect(full.json.lesson.body).toContain('## ');
    expect(full.json.lesson.cards.length).toBeGreaterThanOrEqual(3);
    expect(full.json.lesson.readMinutes).toBeGreaterThan(1);
    const search = await call('GET', '/lessons?q=kahneman', { token: u.token });
    expect(search.json.lessons.length).toBeGreaterThan(0);
  });

  it('counts reads toward the daily goal and starts a streak', async () => {
    const u = await register();
    let user: Json = {};
    for (const id of ['a', 'b', 'c', 'd', 'e', 'e']) {
      user = (await call('POST', '/me/progress', { token: u.token, body: { kind: 'card', id, date: today } })).json.user;
    }
    expect(user.progress.readIds).toHaveLength(5);
    expect(user.streak).toBe(1);
    expect(user.lastGoalDate).toBe(today);
  });

  it('keeps user lessons private, lets only editors publish, and preserves card ids on edit', async () => {
    const author = await register();
    const other = await register();
    const editor = await register();
    await setRole(editor.email, 'editor');

    expect((await call('POST', '/lessons', { token: author.token, body: { ...lessonBody, visibility: 'public' } })).status).toBe(403);
    const created = await call('POST', '/lessons', { token: author.token, body: lessonBody });
    expect(created.status).toBe(201);
    const lesson = created.json.lesson;
    expect(lesson.visibility).toBe('private');

    expect((await call('GET', `/lessons/${lesson.id}`, { token: other.token })).status).toBe(404);
    expect((await call('PUT', `/lessons/${lesson.id}`, { token: other.token, body: lessonBody })).status).toBe(404);

    const edited = await call('PUT', `/lessons/${lesson.id}`, {
      token: author.token,
      body: { ...lessonBody, title: 'Renamed', cards: [lesson.cards[0], { type: 'quote', title: 'New', body: 'New' }] },
    });
    expect(edited.json.lesson.cards[0].id).toBe(lesson.cards[0].id);

    const published = await call('PUT', `/lessons/${lesson.id}`, { token: editor.token, body: { ...lessonBody, visibility: 'public' } });
    expect(published.status).toBe(200);
    expect((await call('GET', `/lessons/${lesson.id}`, { token: other.token })).status).toBe(200);
  });
});

describe('stashes', () => {
  it('toggles items, resolves them, isolates users, and cleans up deleted lessons', async () => {
    const u = await register();
    const other = await register();
    const { json: { stashes } } = await call('GET', '/stashes', { token: u.token });
    expect(stashes).toHaveLength(1);
    const saved = stashes[0];

    const lesson = (await call('POST', '/lessons', { token: u.token, body: lessonBody })).json.lesson;
    await call('POST', `/stashes/${saved.id}/items`, { token: u.token, body: { kind: 'lesson', refId: lesson.id } });
    await call('POST', `/stashes/${saved.id}/items`, { token: u.token, body: { kind: 'card', refId: 'deep-work-1' } });
    const detail = await call('GET', `/stashes/${saved.id}`, { token: u.token });
    expect(detail.json.items.map((i: Json) => i.kind)).toEqual(['card', 'lesson']);
    expect(detail.json.items[0].card.lessonTitle).toMatch(/Deep Work/);

    expect((await call('GET', `/stashes/${saved.id}`, { token: other.token })).status).toBe(404);
    expect((await call('DELETE', `/stashes/${saved.id}`, { token: u.token })).status).toBe(400);
    expect((await call('POST', '/stashes', { token: u.token, body: { name: 'X', icon: 'not-an-icon' } })).status).toBe(400);

    await call('DELETE', `/lessons/${lesson.id}`, { token: u.token });
    const after = await call('GET', '/stashes', { token: u.token });
    expect(after.json.stashes[0].items).toHaveLength(1);
  });
});

describe('admin', () => {
  it('is admin-only and manages roles, disabling and deletion', async () => {
    const adminU = await register('Admin');
    const target = await register('Target');
    expect((await call('GET', '/admin/users', { token: target.token })).status).toBe(403);
    await setRole(adminU.email, 'admin');

    const list = await call('GET', `/admin/users?q=${encodeURIComponent(target.email)}`, { token: adminU.token });
    expect(list.json.users).toHaveLength(1);
    expect(JSON.stringify(list.json)).not.toContain('passwordHash');

    expect((await call('PATCH', `/admin/users/${adminU.id}`, { token: adminU.token, body: { role: 'user' } })).status).toBe(400);
    const promoted = await call('PATCH', `/admin/users/${target.id}`, { token: adminU.token, body: { role: 'editor' } });
    expect(promoted.json.user.role).toBe('editor');

    await call('PATCH', `/admin/users/${target.id}`, { token: adminU.token, body: { disabled: true } });
    expect((await call('GET', '/me', { token: target.token })).status).toBe(403);
    expect((await call('POST', '/auth/refresh', { body: { refreshToken: target.refresh } })).status).toBe(401);
    expect((await call('POST', '/auth/login', { body: { email: target.email, password: 'correct horse' } })).status).toBe(403);

    expect((await call('DELETE', `/admin/users/${target.id}`, { token: adminU.token })).status).toBe(200);
    const { stashes, users } = await db.cols();
    expect(await users.countDocuments({ email: target.email })).toBe(0);
    expect(await stashes.countDocuments({ userId: new (await import('mongodb')).ObjectId(target.id) })).toBe(0);
  });
});
