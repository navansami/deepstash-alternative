import { Hono } from 'hono';
import { HTTPException } from 'hono/http-exception';
import { ObjectId } from 'mongodb';
import { z } from 'zod';

import { burnPasswordCheck, hashPassword, issueTokens, sha256, verifyPassword, type AppEnv } from '../auth.js';
import { cols, type UserDoc } from '../db.js';
import { body, publicUser } from '../util.js';

const MAX_FAILED_LOGINS = 5;
const LOCK_MS = 15 * 60 * 1000;

export const email = z.string().trim().toLowerCase().email('must be a valid email').max(254);
export const password = z.string().min(8, 'must be at least 8 characters').max(128);
const name = z.string().trim().min(1, 'is required').max(60);

export const auth = new Hono<AppEnv>();

auth.post('/register', async (c) => {
  const input = await body(c, z.object({ email, password, name }));
  const { users, stashes } = await cols();
  const now = new Date();
  const user: UserDoc = {
    _id: new ObjectId(),
    email: input.email,
    name: input.name,
    passwordHash: await hashPassword(input.password),
    role: 'user',
    disabled: false,
    topics: [],
    likedCardIds: [],
    completedLessonIds: [],
    progress: { date: '', readIds: [] },
    streak: 0,
    lastGoalDate: '',
    failedLogins: 0,
    lockUntil: null,
    createdAt: now,
    updatedAt: now,
    lastLoginAt: now,
  };
  try {
    await users.insertOne(user);
  } catch (e) {
    if ((e as { code?: number }).code === 11000) {
      throw new HTTPException(409, { message: 'An account with that email already exists' });
    }
    throw e;
  }
  await stashes.insertOne({
    _id: new ObjectId(),
    userId: user._id,
    name: 'Saved',
    icon: 'bookmark',
    items: [],
    createdAt: now,
    updatedAt: now,
  });
  return c.json({ user: publicUser(user), ...(await issueTokens(user)) }, 201);
});

auth.post('/login', async (c) => {
  const input = await body(c, z.object({ email, password: z.string().min(1).max(128) }));
  const { users } = await cols();
  const user = await users.findOne({ email: input.email });
  const invalid = new HTTPException(401, { message: 'Invalid email or password' });

  if (!user) {
    await burnPasswordCheck(input.password);
    throw invalid;
  }
  if (user.lockUntil && user.lockUntil > new Date()) {
    throw new HTTPException(429, { message: 'Too many failed attempts. Try again in a few minutes.' });
  }
  if (!(await verifyPassword(input.password, user.passwordHash))) {
    const failed = user.failedLogins + 1;
    await users.updateOne(
      { _id: user._id },
      failed >= MAX_FAILED_LOGINS
        ? { $set: { failedLogins: 0, lockUntil: new Date(Date.now() + LOCK_MS) } }
        : { $set: { failedLogins: failed } },
    );
    throw invalid;
  }
  if (user.disabled) throw new HTTPException(403, { message: 'This account has been disabled' });

  await users.updateOne({ _id: user._id }, { $set: { failedLogins: 0, lockUntil: null, lastLoginAt: new Date() } });
  return c.json({ user: publicUser(user), ...(await issueTokens(user)) });
});

/** Rotates the refresh token: the old one stops working as soon as it's used. */
auth.post('/refresh', async (c) => {
  const { refreshToken } = await body(c, z.object({ refreshToken: z.string().min(20).max(200) }));
  const { sessions, users } = await cols();
  const session = await sessions.findOneAndDelete({ tokenHash: sha256(refreshToken) });
  const expired = new HTTPException(401, { message: 'Session expired' });
  if (!session || session.expiresAt < new Date()) throw expired;
  const user = await users.findOne({ _id: session.userId });
  if (!user) throw expired;
  if (user.disabled) throw new HTTPException(403, { message: 'This account has been disabled' });
  return c.json({ user: publicUser(user), ...(await issueTokens(user)) });
});

auth.post('/logout', async (c) => {
  const { refreshToken } = await body(c, z.object({ refreshToken: z.string().max(200) }));
  const { sessions } = await cols();
  await sessions.deleteOne({ tokenHash: sha256(refreshToken) });
  return c.json({ ok: true });
});
