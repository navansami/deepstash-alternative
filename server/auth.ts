import { createHash, randomBytes, scrypt as scryptCb, timingSafeEqual } from 'node:crypto';
import { promisify } from 'node:util';
import type { Context, MiddlewareHandler } from 'hono';
import { HTTPException } from 'hono/http-exception';
import { SignJWT, jwtVerify } from 'jose';
import { ObjectId } from 'mongodb';

import { cols, type Role, type UserDoc } from './db.js';

const scrypt = promisify(scryptCb) as (pw: string, salt: Buffer, len: number, opts: object) => Promise<Buffer>;
const SCRYPT = { N: 16384, r: 8, p: 1, maxmem: 64 * 1024 * 1024 };
const KEYLEN = 64;

export const ACCESS_TTL_SECONDS = 15 * 60;
export const REFRESH_TTL_MS = 30 * 24 * 60 * 60 * 1000;

// ---------- passwords ----------

export async function hashPassword(password: string): Promise<string> {
  const salt = randomBytes(16);
  const hash = await scrypt(password, salt, KEYLEN, SCRYPT);
  return `scrypt$${salt.toString('base64')}$${hash.toString('base64')}`;
}

export async function verifyPassword(password: string, stored: string): Promise<boolean> {
  const [scheme, saltB64, hashB64] = stored.split('$');
  if (scheme !== 'scrypt' || !saltB64 || !hashB64) return false;
  const expected = Buffer.from(hashB64, 'base64');
  const actual = await scrypt(password, Buffer.from(saltB64, 'base64'), expected.length, SCRYPT);
  return timingSafeEqual(actual, expected);
}

/** Used when the email doesn't exist so response time doesn't reveal that. */
let dummyHash: Promise<string> | null = null;
export async function burnPasswordCheck(password: string): Promise<void> {
  dummyHash ??= hashPassword('not-a-real-password');
  await verifyPassword(password, await dummyHash);
}

// ---------- tokens ----------

function jwtKey(): Uint8Array {
  const secret = process.env.JWT_SECRET;
  if (!secret || secret.length < 32) throw new Error('JWT_SECRET must be set to at least 32 characters');
  return new TextEncoder().encode(secret);
}

export async function signAccessToken(user: Pick<UserDoc, '_id' | 'role'>): Promise<string> {
  return new SignJWT({ role: user.role })
    .setProtectedHeader({ alg: 'HS256' })
    .setSubject(user._id.toHexString())
    .setIssuedAt()
    .setExpirationTime(`${ACCESS_TTL_SECONDS}s`)
    .setIssuer('kernel')
    .sign(jwtKey());
}

export const sha256 = (s: string) => createHash('sha256').update(s).digest('hex');

/** Creates a session and returns a token pair. The refresh token is opaque and stored hashed. */
export async function issueTokens(user: UserDoc) {
  const { sessions } = await cols();
  const refreshToken = randomBytes(32).toString('base64url');
  await sessions.insertOne({
    _id: new ObjectId(),
    userId: user._id,
    tokenHash: sha256(refreshToken),
    expiresAt: new Date(Date.now() + REFRESH_TTL_MS),
    createdAt: new Date(),
  });
  return { accessToken: await signAccessToken(user), refreshToken, expiresIn: ACCESS_TTL_SECONDS };
}

// ---------- middleware ----------

export type AppEnv = { Variables: { user: UserDoc } };

export const requireAuth: MiddlewareHandler<AppEnv> = async (c, next) => {
  const header = c.req.header('Authorization') ?? '';
  const token = header.startsWith('Bearer ') ? header.slice(7) : '';
  if (!token) throw new HTTPException(401, { message: 'Sign in required' });

  let sub: string | undefined;
  try {
    const { payload } = await jwtVerify(token, jwtKey(), { issuer: 'kernel', algorithms: ['HS256'] });
    sub = payload.sub;
  } catch {
    throw new HTTPException(401, { message: 'Session expired' });
  }
  if (!sub || !ObjectId.isValid(sub)) throw new HTTPException(401, { message: 'Session expired' });

  // Load the user on every request so role changes and disabling take effect immediately.
  const { users } = await cols();
  const user = await users.findOne({ _id: new ObjectId(sub) });
  if (!user) throw new HTTPException(401, { message: 'Account not found' });
  if (user.disabled) throw new HTTPException(403, { message: 'This account has been disabled' });
  c.set('user', user);
  await next();
};

export const requireRole =
  (...roles: Role[]): MiddlewareHandler<AppEnv> =>
  async (c, next) => {
    if (!roles.includes(c.get('user').role)) throw new HTTPException(403, { message: 'Not allowed' });
    await next();
  };

export const canEditAny = (role: Role) => role === 'editor' || role === 'admin';

export function currentUser(c: Context<AppEnv>): UserDoc {
  return c.get('user');
}
