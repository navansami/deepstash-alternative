import { randomBytes } from 'node:crypto';
import { Hono } from 'hono';
import { HTTPException } from 'hono/http-exception';
import { ObjectId, type Filter } from 'mongodb';
import { z } from 'zod';

import { canEditAny, requireAuth, type AppEnv } from '../auth.js';
import { cols, type LessonDoc, type UserDoc } from '../db.js';
import { TOPIC_IDS } from '../topics.js';
import {
  body, canEditLesson, canViewLesson, dateSchema, escapeRegex, feedCard, lessonFull, lessonSummary,
  notFound, parse, pullFromStashes, seededShuffle,
} from '../util.js';

export const FEED_PAGE_SIZE = 8;

const cardInput = z.object({
  id: z.string().max(60).optional(),
  type: z.enum(['idea', 'quote', 'tip']),
  title: z.string().trim().min(1).max(80),
  body: z.string().trim().min(1).max(400),
});

export const lessonInput = z.object({
  title: z.string().trim().min(3).max(120),
  summary: z.string().trim().min(1).max(280),
  topic: z.enum(TOPIC_IDS),
  source: z.string().trim().max(120).default(''),
  author: z.string().trim().max(120).default(''),
  body: z.string().trim().min(50, 'should be at least a short paragraph').max(20_000),
  takeaways: z.array(z.string().trim().min(1).max(200)).max(8).default([]),
  cards: z.array(cardInput).min(1, 'add at least one key idea').max(6),
  visibility: z.enum(['public', 'private']).default('private'),
});

export const readMinutes = (markdown: string) =>
  Math.max(1, Math.round(markdown.split(/\s+/).filter(Boolean).length / 200));

export const slugify = (s: string) =>
  s.toLowerCase().normalize('NFKD').replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '').slice(0, 60) || 'lesson';

const newCardId = () => `c_${randomBytes(6).toString('base64url')}`;

/** Visible to this user: public, their own, or everything for editors/admins. */
function visibleTo(u: UserDoc): Filter<LessonDoc> {
  return u.role === 'user' ? { $or: [{ visibility: 'public' }, { authorId: u._id }] } : {};
}

async function findLesson(idOrSlug: string): Promise<LessonDoc | null> {
  const { lessons } = await cols();
  return ObjectId.isValid(idOrSlug) && idOrSlug.length === 24
    ? lessons.findOne({ _id: new ObjectId(idOrSlug) })
    : lessons.findOne({ slug: idOrSlug });
}

export const lessons = new Hono<AppEnv>();
lessons.use('*', requireAuth);

lessons.get('/', async (c) => {
  const user = c.get('user');
  const q = parse(
    z.object({
      topic: z.enum(TOPIC_IDS).optional(),
      q: z.string().trim().max(100).optional(),
      mine: z.enum(['1', 'true']).optional(),
      skip: z.coerce.number().int().min(0).max(10_000).default(0),
      limit: z.coerce.number().int().min(1).max(50).default(30),
    }),
    c.req.query(),
  );
  const and: Filter<LessonDoc>[] = [visibleTo(user)];
  if (q.topic) and.push({ topic: q.topic });
  if (q.mine) and.push({ authorId: user._id });
  if (q.q) {
    const rx = new RegExp(escapeRegex(q.q), 'i');
    and.push({ $or: [{ title: rx }, { summary: rx }, { author: rx }, { source: rx }, { 'cards.title': rx }] });
  }
  const { lessons: col } = await cols();
  const docs = await col
    .find({ $and: and }, { projection: { body: 0 } })
    .sort({ createdAt: -1 })
    .skip(q.skip)
    .limit(q.limit + 1)
    .toArray();
  return c.json({
    lessons: docs.slice(0, q.limit).map((l) => lessonSummary(l, user)),
    hasMore: docs.length > q.limit,
  });
});

lessons.get('/:id', async (c) => {
  const user = c.get('user');
  const lesson = await findLesson(c.req.param('id'));
  if (!lesson || !canViewLesson(lesson, user)) throw notFound('Lesson');
  return c.json({ lesson: lessonFull(lesson, user) });
});

lessons.post('/', async (c) => {
  const user = c.get('user');
  const input = await body(c, lessonInput);
  if (input.visibility === 'public' && !canEditAny(user.role)) {
    throw new HTTPException(403, { message: 'Only editors can publish lessons to everyone' });
  }
  const { lessons: col } = await cols();
  const now = new Date();
  const doc: LessonDoc = {
    _id: new ObjectId(),
    slug: `${slugify(input.title)}-${randomBytes(3).toString('hex')}`,
    ...input,
    cards: input.cards.map((card) => ({ ...card, id: newCardId() })),
    readMinutes: readMinutes(input.body),
    authorId: user._id,
    createdAt: now,
    updatedAt: now,
  };
  await col.insertOne(doc);
  return c.json({ lesson: lessonFull(doc, user) }, 201);
});

lessons.put('/:id', async (c) => {
  const user = c.get('user');
  const lesson = await findLesson(c.req.param('id'));
  if (!lesson || !canViewLesson(lesson, user)) throw notFound('Lesson');
  if (!canEditLesson(lesson, user)) throw new HTTPException(403, { message: 'You can only edit your own lessons' });
  const input = await body(c, lessonInput);
  if (input.visibility === 'public' && lesson.visibility !== 'public' && !canEditAny(user.role)) {
    throw new HTTPException(403, { message: 'Only editors can publish lessons to everyone' });
  }
  // Keep ids of existing cards so likes and stashes survive edits.
  const existing = new Set(lesson.cards.map((card) => card.id));
  const cards = input.cards.map((card) => ({
    ...card,
    id: card.id && existing.has(card.id) ? card.id : newCardId(),
  }));
  const { lessons: col } = await cols();
  const updated = await col.findOneAndUpdate(
    { _id: lesson._id },
    { $set: { ...input, cards, readMinutes: readMinutes(input.body), updatedAt: new Date() } },
    { returnDocument: 'after' },
  );
  const removed = lesson.cards.filter((card) => !cards.some((n) => n.id === card.id));
  if (removed.length) await pullFromStashes([{ _id: new ObjectId(), cards: removed }]);
  return c.json({ lesson: lessonFull(updated!, user) });
});

lessons.delete('/:id', async (c) => {
  const user = c.get('user');
  const lesson = await findLesson(c.req.param('id'));
  if (!lesson || !canViewLesson(lesson, user)) throw notFound('Lesson');
  if (!canEditLesson(lesson, user)) throw new HTTPException(403, { message: 'You can only delete your own lessons' });
  const { lessons: col } = await cols();
  await col.deleteOne({ _id: lesson._id });
  await pullFromStashes([lesson]);
  return c.json({ ok: true });
});

// ---------- feed ----------

export const feed = new Hono<AppEnv>();
feed.use('*', requireAuth);

/** Today's cards from public lessons in the user's topics, in a stable per-user, per-day order. */
feed.get('/', async (c) => {
  const user = c.get('user');
  const q = parse(
    z.object({ date: dateSchema, page: z.coerce.number().int().min(0).max(100).default(0) }),
    c.req.query(),
  );
  const { lessons: col } = await cols();
  const docs = await col
    .find({ visibility: 'public', topic: { $in: user.topics } }, { projection: { body: 0, takeaways: 0 } })
    .toArray();
  const all = seededShuffle(
    docs.flatMap((l) => l.cards.map((card) => feedCard(l, card))),
    `${user._id.toHexString()}:${q.date}`,
  );
  const end = FEED_PAGE_SIZE * (q.page + 1);
  return c.json({ cards: all.slice(FEED_PAGE_SIZE * q.page, end), hasMore: all.length > end });
});

