import { Hono } from 'hono';
import { HTTPException } from 'hono/http-exception';
import { z } from 'zod';

import { hashPassword, issueTokens, requireAuth, verifyPassword, type AppEnv } from '../auth.js';
import { cols } from '../db.js';
import { TOPIC_IDS } from '../topics.js';
import { DAILY_GOAL, body, dateSchema, deleteUserCascade, previousDay, publicUser } from '../util.js';
import { email, password } from './auth.js';

export const me = new Hono<AppEnv>();
me.use('*', requireAuth);

me.get('/', (c) => c.json({ user: publicUser(c.get('user')) }));

me.patch('/', async (c) => {
  const input = await body(
    c,
    z
      .object({
        name: z.string().trim().min(1).max(60).optional(),
        email: email.optional(),
        topics: z.array(z.enum(TOPIC_IDS)).min(1).max(TOPIC_IDS.length).optional(),
        currentPassword: z.string().max(128).optional(),
      })
      .strict(),
  );
  const user = c.get('user');
  const { users } = await cols();
  const set: Record<string, unknown> = { updatedAt: new Date() };

  if (input.name !== undefined) set.name = input.name;
  if (input.topics !== undefined) set.topics = [...new Set(input.topics)];
  if (input.email !== undefined && input.email !== user.email) {
    if (!input.currentPassword || !(await verifyPassword(input.currentPassword, user.passwordHash))) {
      throw new HTTPException(400, { message: 'Enter your current password to change your email' });
    }
    set.email = input.email;
  }

  try {
    const updated = await users.findOneAndUpdate({ _id: user._id }, { $set: set }, { returnDocument: 'after' });
    return c.json({ user: publicUser(updated!) });
  } catch (e) {
    if ((e as { code?: number }).code === 11000) {
      throw new HTTPException(409, { message: 'That email is already in use' });
    }
    throw e;
  }
});

/** Changing the password signs out every other device. */
me.post('/password', async (c) => {
  const input = await body(c, z.object({ currentPassword: z.string().max(128), newPassword: password }));
  const user = c.get('user');
  if (!(await verifyPassword(input.currentPassword, user.passwordHash))) {
    throw new HTTPException(400, { message: 'Current password is incorrect' });
  }
  const { users, sessions } = await cols();
  await users.updateOne(
    { _id: user._id },
    { $set: { passwordHash: await hashPassword(input.newPassword), updatedAt: new Date() } },
  );
  await sessions.deleteMany({ userId: user._id });
  return c.json({ user: publicUser(user), ...(await issueTokens(user)) });
});

me.delete('/', async (c) => {
  const input = await body(c, z.object({ password: z.string().max(128) }));
  const user = c.get('user');
  if (!(await verifyPassword(input.password, user.passwordHash))) {
    throw new HTTPException(400, { message: 'Password is incorrect' });
  }
  await deleteUserCascade(user._id);
  return c.json({ ok: true });
});

me.post('/likes/:cardId', async (c) => {
  const cardId = c.req.param('cardId').slice(0, 100);
  const user = c.get('user');
  const { users } = await cols();
  const liked = !user.likedCardIds.includes(cardId);
  await users.updateOne(
    { _id: user._id },
    liked ? { $addToSet: { likedCardIds: cardId } } : { $pull: { likedCardIds: cardId } },
  );
  return c.json({ liked });
});

/** Records a card read or lesson completion for the user's local day and updates the streak. */
me.post('/progress', async (c) => {
  const input = await body(
    c,
    z.object({ kind: z.enum(['card', 'lesson']), id: z.string().min(1).max(100), date: dateSchema }),
  );
  const user = c.get('user');
  const { users } = await cols();

  const readIds = user.progress.date === input.date ? [...user.progress.readIds] : [];
  if (!readIds.includes(input.id)) readIds.push(input.id);

  let { streak, lastGoalDate } = user;
  if (readIds.length >= DAILY_GOAL && lastGoalDate !== input.date) {
    streak = lastGoalDate === previousDay(input.date) ? streak + 1 : 1;
    lastGoalDate = input.date;
  }

  const update: Record<string, unknown> = {
    $set: { progress: { date: input.date, readIds }, streak, lastGoalDate },
  };
  if (input.kind === 'lesson') update.$addToSet = { completedLessonIds: input.id };
  const updated = await users.findOneAndUpdate({ _id: user._id }, update, { returnDocument: 'after' });
  return c.json({ user: publicUser(updated!) });
});
