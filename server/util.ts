import type { Context } from 'hono';
import { HTTPException } from 'hono/http-exception';
import { ObjectId } from 'mongodb';
import { z } from 'zod';

import { cols, type LessonDoc, type StashDoc, type UserDoc } from './db.js';

export const DAILY_GOAL = 5;

/** Parses a JSON body against a schema; 400 with a readable message on failure. */
export async function body<T extends z.ZodTypeAny>(c: Context, schema: T): Promise<z.infer<T>> {
  let raw: unknown;
  try {
    raw = await c.req.json();
  } catch {
    throw new HTTPException(400, { message: 'Request body must be JSON' });
  }
  return parse(schema, raw);
}

export function parse<T extends z.ZodTypeAny>(schema: T, raw: unknown): z.infer<T> {
  const r = schema.safeParse(raw);
  if (!r.success) {
    const issue = r.error.issues[0];
    const path = issue?.path.join('.');
    throw new HTTPException(400, { message: path ? `${path}: ${issue?.message}` : (issue?.message ?? 'Invalid input') });
  }
  return r.data;
}

export function oid(id: string, what = 'Item'): ObjectId {
  if (!ObjectId.isValid(id)) throw new HTTPException(404, { message: `${what} not found` });
  return new ObjectId(id);
}

export const notFound = (what: string) => new HTTPException(404, { message: `${what} not found` });

export const escapeRegex = (s: string) => s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');

// ---------- dates (user's local calendar day, sent by the client) ----------

export const dateSchema = z
  .string()
  .regex(/^\d{4}-\d{2}-\d{2}$/, 'must be YYYY-MM-DD')
  .refine((d) => {
    // Accept only "today" somewhere on Earth: within ±1 day of the server's UTC date.
    const t = Date.parse(`${d}T00:00:00Z`);
    return !Number.isNaN(t) && Math.abs(t - Date.now()) < 2 * 86_400_000;
  }, 'is not a current date');

export function previousDay(d: string): string {
  const t = new Date(`${d}T00:00:00Z`);
  t.setUTCDate(t.getUTCDate() - 1);
  return t.toISOString().slice(0, 10);
}

// ---------- deterministic shuffle ----------

function mulberry32(seed: number) {
  return () => {
    seed |= 0;
    seed = (seed + 0x6d2b79f5) | 0;
    let t = Math.imul(seed ^ (seed >>> 15), 1 | seed);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

export function seededShuffle<T>(items: T[], seedText: string): T[] {
  let seed = 0;
  for (const ch of seedText) seed = (Math.imul(31, seed) + ch.charCodeAt(0)) | 0;
  const rand = mulberry32(seed);
  const out = [...items];
  for (let i = out.length - 1; i > 0; i--) {
    const j = Math.floor(rand() * (i + 1));
    [out[i], out[j]] = [out[j]!, out[i]!];
  }
  return out;
}

// ---------- serializers (never expose hashes or internal counters) ----------

export function publicUser(u: UserDoc) {
  return {
    id: u._id.toHexString(),
    email: u.email,
    name: u.name,
    role: u.role,
    topics: u.topics,
    likedCardIds: u.likedCardIds,
    completedLessonIds: u.completedLessonIds,
    progress: u.progress,
    streak: u.streak,
    lastGoalDate: u.lastGoalDate,
    dailyGoal: DAILY_GOAL,
    createdAt: u.createdAt,
  };
}

export function adminUser(u: UserDoc) {
  return {
    id: u._id.toHexString(),
    email: u.email,
    name: u.name,
    role: u.role,
    disabled: u.disabled,
    createdAt: u.createdAt,
    lastLoginAt: u.lastLoginAt,
    locked: !!u.lockUntil && u.lockUntil > new Date(),
  };
}

export function lessonSummary(l: LessonDoc, viewer: UserDoc) {
  return {
    id: l._id.toHexString(),
    slug: l.slug,
    title: l.title,
    summary: l.summary,
    topic: l.topic,
    source: l.source,
    author: l.author,
    readMinutes: l.readMinutes,
    cardCount: l.cards.length,
    visibility: l.visibility,
    completed: viewer.completedLessonIds.includes(l._id.toHexString()),
    canEdit: canEditLesson(l, viewer),
    createdAt: l.createdAt,
    updatedAt: l.updatedAt,
  };
}

export function lessonFull(l: LessonDoc, viewer: UserDoc) {
  return { ...lessonSummary(l, viewer), body: l.body, takeaways: l.takeaways, cards: l.cards };
}

export function feedCard(l: LessonDoc, card: LessonDoc['cards'][number]) {
  return {
    ...card,
    lessonId: l._id.toHexString(),
    lessonTitle: l.title,
    topic: l.topic,
    source: l.source,
    author: l.author,
    readMinutes: l.readMinutes,
  };
}

export function publicStash(s: StashDoc) {
  return {
    id: s._id.toHexString(),
    name: s.name,
    icon: s.icon,
    items: s.items.map((i) => ({ kind: i.kind, refId: i.refId, addedAt: i.addedAt })),
    createdAt: s.createdAt,
  };
}

export function canViewLesson(l: LessonDoc, u: UserDoc) {
  return l.visibility === 'public' || l.authorId?.equals(u._id) || u.role !== 'user';
}

export function canEditLesson(l: LessonDoc, u: UserDoc) {
  return u.role === 'editor' || u.role === 'admin' || !!l.authorId?.equals(u._id);
}

// ---------- account deletion ----------

/** Removes a user and everything that belongs only to them. Public lessons they wrote are kept, unattributed. */
export async function deleteUserCascade(userId: ObjectId): Promise<void> {
  const { users, sessions, stashes, lessons } = await cols();
  const privateLessons = await lessons
    .find({ authorId: userId, visibility: 'private' }, { projection: { _id: 1, cards: 1 } })
    .toArray();
  await Promise.all([
    users.deleteOne({ _id: userId }),
    sessions.deleteMany({ userId }),
    stashes.deleteMany({ userId }),
    lessons.deleteMany({ authorId: userId, visibility: 'private' }),
    lessons.updateMany({ authorId: userId }, { $set: { authorId: null } }),
  ]);
  if (privateLessons.length) await pullFromStashes(privateLessons);
}

/** Removes deleted lessons (and their cards) from everyone's stashes. */
export async function pullFromStashes(deleted: Pick<LessonDoc, '_id' | 'cards'>[]): Promise<void> {
  const { stashes } = await cols();
  const lessonIds = deleted.map((l) => l._id.toHexString());
  const cardIds = deleted.flatMap((l) => l.cards.map((c) => c.id));
  // Lesson ids (ObjectId hex) and card ids never collide, so one $in covers both kinds.
  const refIds = [...lessonIds, ...cardIds];
  if (refIds.length) await stashes.updateMany({ 'items.refId': { $in: refIds } }, { $pull: { items: { refId: { $in: refIds } } } });
}
