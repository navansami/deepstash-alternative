import { Hono } from 'hono';
import { cors } from 'hono/cors';
import { HTTPException } from 'hono/http-exception';
import { secureHeaders } from 'hono/secure-headers';

import type { AppEnv } from './auth.js';
import { admin } from './routes/admin.js';
import { auth } from './routes/auth.js';
import { feed, lessons } from './routes/lessons.js';
import { me } from './routes/me.js';
import { stashes } from './routes/stashes.js';
import { STASH_ICONS, TOPICS } from './topics.js';

const extraOrigins = (process.env.CORS_ORIGINS ?? '')
  .split(',')
  .map((s) => s.trim())
  .filter(Boolean);
const localhost = /^http:\/\/(localhost|127\.0\.0\.1)(:\d+)?$/;

export const app = new Hono<AppEnv>().basePath('/api');

app.use('*', secureHeaders());
app.use(
  '*',
  cors({
    // Production web is same-origin; this only matters for local Flutter web dev and listed origins.
    origin: (origin) => (localhost.test(origin) || extraOrigins.includes(origin) ? origin : null),
    allowHeaders: ['Authorization', 'Content-Type'],
    allowMethods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    maxAge: 600,
  }),
);

app.get('/health', (c) => c.json({ ok: true }));
app.get('/topics', (c) => c.json({ topics: TOPICS, stashIcons: STASH_ICONS }));
app.route('/auth', auth);
app.route('/me', me);
app.route('/lessons', lessons);
app.route('/feed', feed);
app.route('/stashes', stashes);
app.route('/admin', admin);

app.notFound((c) => c.json({ error: 'Not found' }, 404));
app.onError((err, c) => {
  if (err instanceof HTTPException) return c.json({ error: err.message }, err.status);
  console.error(err);
  return c.json({ error: 'Something went wrong' }, 500);
});
