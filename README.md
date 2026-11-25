# Kernel

A microlearning app that gives you full lessons from great nonfiction, plus short key-idea cards, instead of a social-media feed.

- **Flutter** app (web, Android, iOS, Windows) in `lib/`
- **API**: TypeScript + [Hono](https://hono.dev) running as one Vercel serverless function (`api/index.ts` → `server/`)
- **Database**: MongoDB Atlas

## Features
- **Accounts:** email and password sign-up and sign-in, profile editing, password change (signs out other devices) and account deletion.
- **Roles:** `user` reads, saves and writes *private* lessons. `editor` can also publish lessons and edit any lesson. `admin` can also manage users.
- **Admin screen:** search users, filter by role, change roles, disable or enable accounts (signs the user out everywhere) and delete accounts.
- **Full lessons:** markdown articles with sections, key takeaways and 3–5 key-idea cards. There are 16 built-in lessons across 8 topics.
- **Daily feed:** a vertical swipe through key-idea cards from your topics. The order is stable for the day, and each card links to its full lesson.
- **Goal and streak:** reading 5 ideas a day keeps your streak going, and you can mark lessons complete.
- **Stashes:** save lessons or individual ideas into named collections, each with its own icon.
- **Lesson editor:** markdown with a live preview, takeaways and card editor.

## Security
- Passwords are hashed with scrypt, using a random salt for each password and constant-time comparison.
- Access tokens are short-lived (15 min) HS256 JWTs. Refresh tokens are random, **stored only as SHA-256 hashes**, rotated on every use, and expire after 30 days (MongoDB TTL index).
- The account is loaded on every request, so disabling a user or changing their role takes effect immediately.
- After 5 failed sign-ins the account locks for 15 minutes. Sign-in responses don't reveal whether an email exists.
- All input is validated with zod. Responses never include password hashes or internal counters.
- In production, CORS allows only the app's own origin plus local dev; add more with `CORS_ORIGINS`.
- Secrets live only in `.env.local` (git-ignored) and in Vercel environment variables. See `.env.example`.

## Setup

### 1. Environment
```sh
cp .env.example .env.local   # then fill in MONGODB_URI and JWT_SECRET
npm install
npm run seed                 # loads the built-in lessons into Atlas (safe to re-run)
```

### 2. Run locally
```sh
npm run dev                  # API on http://localhost:3000/api
flutter run -d chrome        # app (debug builds call localhost:3000)
```
For a phone or emulator, point the app at your machine: `flutter run --dart-define=API_BASE=http://10.0.2.2:3000/api` (Android emulator) or use your LAN IP.

### 3. Make yourself an admin
Register in the app, then:
```sh
npm run make-admin -- you@example.com          # or: ... you@example.com editor
```

### Tests
```sh
npm test        # API integration tests against a throwaway in-memory MongoDB
flutter test    # client tests (API client, markdown, full sign-in → lesson flow)
```

## Deploy (Vercel)
1. In **Vercel → Project → Settings → Environment Variables**, add `MONGODB_URI`, `JWT_SECRET` (and optionally `MONGODB_DB`, `CORS_ORIGINS`) for Production and Preview.
2. In **Atlas → Network Access**, allow connections from Vercel. Serverless functions don't have fixed IPs, so use `0.0.0.0/0` together with a strong database password, or set up the Vercel ↔ Atlas integration.
3. Push to `main`. `vercel.json` runs `npm ci`, builds Flutter web with `vercel-build.sh`, serves `build/web`, and routes `/api/*` to the function.

## Structure
```
api/index.ts            Vercel entry → Hono app
server/
  app.ts                routes, CORS, error handling
  auth.ts               password hashing, JWTs, sessions, auth middleware
  db.ts                 Mongo connection (cached), types, indexes
  routes/               auth, me, lessons + feed, stashes, admin
  seed/                 built-in lessons
  scripts/              seed, make-admin
lib/
  core/                 API client (auto token refresh), models, topics/icons
  state/                Session (auth/account), Stashes
  screens/              auth, topics, feed, explore, lesson, editor, stashes, profile, admin
  widgets/              idea card, lesson tile, markdown renderer, save sheet
```
