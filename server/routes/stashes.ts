import { Hono } from 'hono';
import { HTTPException } from 'hono/http-exception';
import { ObjectId } from 'mongodb';
import { z } from 'zod';

import { requireAuth, type AppEnv } from '../auth.js';
import { cols, type StashDoc } from '../db.js';
import { STASH_ICONS } from '../topics.js';
import { body, canViewLesson, feedCard, lessonSummary, notFound, oid, publicStash } from '../util.js';

const name = z.string().trim().min(1, 'is required').max(40);
const icon = z.enum(STASH_ICONS);
const MAX_STASHES = 100;
const MAX_ITEMS = 1000;

export const stashes = new Hono<AppEnv>();
stashes.use('*', requireAuth);

async function ownStash(userId: ObjectId, id: string): Promise<StashDoc> {
  const { stashes: col } = await cols();
  const stash = await col.findOne({ _id: oid(id, 'Stash'), userId });
  if (!stash) throw notFound('Stash');
  return stash;
}

stashes.get('/', async (c) => {
  const { stashes: col } = await cols();
  const list = await col.find({ userId: c.get('user')._id }).sort({ createdAt: 1 }).toArray();
  return c.json({ stashes: list.map(publicStash) });
});

stashes.post('/', async (c) => {
  const input = await body(c, z.object({ name, icon: icon.default('bookmark') }));
  const user = c.get('user');
  const { stashes: col } = await cols();
  if ((await col.countDocuments({ userId: user._id })) >= MAX_STASHES) {
    throw new HTTPException(400, { message: `You can have up to ${MAX_STASHES} stashes` });
  }
  const now = new Date();
  const doc: StashDoc = { _id: new ObjectId(), userId: user._id, ...input, items: [], createdAt: now, updatedAt: now };
  await col.insertOne(doc);
  return c.json({ stash: publicStash(doc) }, 201);
});

/** A stash with its items resolved to lesson summaries and cards. Deleted content is skipped. */
stashes.get('/:id', async (c) => {
  const user = c.get('user');
  const stash = await ownStash(user._id, c.req.param('id'));
  const { lessons } = await cols();
  const lessonIds = stash.items.filter((i) => i.kind === 'lesson' && ObjectId.isValid(i.refId)).map((i) => new ObjectId(i.refId));
  const cardIds = stash.items.filter((i) => i.kind === 'card').map((i) => i.refId);
  const docs = await lessons
    .find({ $or: [{ _id: { $in: lessonIds } }, { 'cards.id': { $in: cardIds } }] }, { projection: { body: 0 } })
    .toArray();
  const visible = docs.filter((l) => canViewLesson(l, user));

  type Resolved =
    | { kind: 'lesson'; addedAt: Date; lesson: ReturnType<typeof lessonSummary> }
    | { kind: 'card'; addedAt: Date; card: ReturnType<typeof feedCard> };
  const items = stash.items.flatMap((i): Resolved[] => {
    if (i.kind === 'lesson') {
      const l = visible.find((d) => d._id.toHexString() === i.refId);
      return l ? [{ kind: 'lesson', addedAt: i.addedAt, lesson: lessonSummary(l, user) }] : [];
    }
    for (const l of visible) {
      const card = l.cards.find((x) => x.id === i.refId);
      if (card) return [{ kind: 'card', addedAt: i.addedAt, card: feedCard(l, card) }];
    }
    return [];
  });
  return c.json({ stash: publicStash(stash), items });
});

stashes.patch('/:id', async (c) => {
  const input = await body(c, z.object({ name: name.optional(), icon: icon.optional() }).strict());
  const stash = await ownStash(c.get('user')._id, c.req.param('id'));
  const { stashes: col } = await cols();
  const updated = await col.findOneAndUpdate(
    { _id: stash._id },
    { $set: { ...input, updatedAt: new Date() } },
    { returnDocument: 'after' },
  );
  return c.json({ stash: publicStash(updated!) });
});

stashes.delete('/:id', async (c) => {
  const user = c.get('user');
  const stash = await ownStash(user._id, c.req.param('id'));
  const { stashes: col } = await cols();
  if ((await col.countDocuments({ userId: user._id })) <= 1) {
    throw new HTTPException(400, { message: 'You need at least one stash' });
  }
  await col.deleteOne({ _id: stash._id });
  return c.json({ ok: true });
});

/** Toggles an item in a stash. */
stashes.post('/:id/items', async (c) => {
  const input = await body(c, z.object({ kind: z.enum(['lesson', 'card']), refId: z.string().min(1).max(100) }));
  const stash = await ownStash(c.get('user')._id, c.req.param('id'));
  const { stashes: col } = await cols();
  const present = stash.items.some((i) => i.kind === input.kind && i.refId === input.refId);
  if (!present && stash.items.length >= MAX_ITEMS) {
    throw new HTTPException(400, { message: 'This stash is full' });
  }
  const updated = await col.findOneAndUpdate(
    { _id: stash._id },
    present
      ? { $pull: { items: { kind: input.kind, refId: input.refId } }, $set: { updatedAt: new Date() } }
      : { $push: { items: { $each: [{ ...input, addedAt: new Date() }], $position: 0 } }, $set: { updatedAt: new Date() } },
    { returnDocument: 'after' },
  );
  return c.json({ stash: publicStash(updated!), saved: !present });
});
