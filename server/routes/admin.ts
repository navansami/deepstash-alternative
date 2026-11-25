import { Hono } from 'hono';
import { HTTPException } from 'hono/http-exception';
import type { Filter } from 'mongodb';
import { z } from 'zod';

import { requireAuth, requireRole, type AppEnv } from '../auth.js';
import { cols, ROLES, type UserDoc } from '../db.js';
import { adminUser, body, deleteUserCascade, escapeRegex, notFound, oid, parse } from '../util.js';

export const admin = new Hono<AppEnv>();
admin.use('*', requireAuth, requireRole('admin'));

admin.get('/users', async (c) => {
  const q = parse(
    z.object({
      q: z.string().trim().max(100).optional(),
      role: z.enum(ROLES as [string, ...string[]]).optional(),
      skip: z.coerce.number().int().min(0).default(0),
      limit: z.coerce.number().int().min(1).max(100).default(50),
    }),
    c.req.query(),
  );
  const filter: Filter<UserDoc> = {};
  if (q.role) filter.role = q.role as UserDoc['role'];
  if (q.q) {
    const rx = new RegExp(escapeRegex(q.q), 'i');
    filter.$or = [{ email: rx }, { name: rx }];
  }
  const { users } = await cols();
  const [list, total] = await Promise.all([
    users.find(filter).sort({ createdAt: -1 }).skip(q.skip).limit(q.limit).toArray(),
    users.countDocuments(filter),
  ]);
  return c.json({ users: list.map(adminUser), total });
});

admin.get('/stats', async (c) => {
  const { users, lessons } = await cols();
  const [userCount, disabled, admins, editors, publicLessons, privateLessons] = await Promise.all([
    users.countDocuments(),
    users.countDocuments({ disabled: true }),
    users.countDocuments({ role: 'admin' }),
    users.countDocuments({ role: 'editor' }),
    lessons.countDocuments({ visibility: 'public' }),
    lessons.countDocuments({ visibility: 'private' }),
  ]);
  return c.json({ users: userCount, disabled, admins, editors, publicLessons, privateLessons });
});

admin.patch('/users/:id', async (c) => {
  const input = await body(
    c,
    z.object({ role: z.enum(ROLES as [string, ...string[]]).optional(), disabled: z.boolean().optional() }).strict(),
  );
  const me = c.get('user');
  const id = oid(c.req.param('id'), 'User');
  if (id.equals(me._id)) throw new HTTPException(400, { message: "You can't change your own role or status" });

  const { users, sessions } = await cols();
  const set: Partial<UserDoc> = { updatedAt: new Date() };
  if (input.role) set.role = input.role as UserDoc['role'];
  if (input.disabled !== undefined) {
    set.disabled = input.disabled;
    if (!input.disabled) Object.assign(set, { failedLogins: 0, lockUntil: null });
  }
  const updated = await users.findOneAndUpdate({ _id: id }, { $set: set }, { returnDocument: 'after' });
  if (!updated) throw notFound('User');
  if (input.disabled) await sessions.deleteMany({ userId: id }); // sign them out everywhere
  return c.json({ user: adminUser(updated) });
});

admin.delete('/users/:id', async (c) => {
  const id = oid(c.req.param('id'), 'User');
  if (id.equals(c.get('user')._id)) {
    throw new HTTPException(400, { message: 'Delete your own account from your profile instead' });
  }
  const { users } = await cols();
  if (!(await users.findOne({ _id: id }, { projection: { _id: 1 } }))) throw notFound('User');
  await deleteUserCascade(id);
  return c.json({ ok: true });
});
