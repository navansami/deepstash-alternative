import { MongoClient, type Collection, type Db, type ObjectId } from 'mongodb';

export type Role = 'user' | 'editor' | 'admin';
export const ROLES: Role[] = ['user', 'editor', 'admin'];

export interface UserDoc {
  _id: ObjectId;
  email: string;
  name: string;
  passwordHash: string;
  role: Role;
  disabled: boolean;
  topics: string[];
  likedCardIds: string[];
  completedLessonIds: string[];
  /** Items read on `date` (the user's local calendar day). */
  progress: { date: string; readIds: string[] };
  streak: number;
  lastGoalDate: string;
  failedLogins: number;
  lockUntil: Date | null;
  createdAt: Date;
  updatedAt: Date;
  lastLoginAt: Date | null;
}

export interface SessionDoc {
  _id: ObjectId;
  userId: ObjectId;
  /** SHA-256 of the refresh token; the raw token is never stored. */
  tokenHash: string;
  expiresAt: Date;
  createdAt: Date;
}

export type CardType = 'idea' | 'quote' | 'tip';

export interface LessonCard {
  id: string;
  type: CardType;
  title: string;
  body: string;
}

export interface LessonDoc {
  _id: ObjectId;
  slug: string;
  title: string;
  summary: string;
  topic: string;
  source: string;
  author: string;
  /** Markdown. */
  body: string;
  takeaways: string[];
  cards: LessonCard[];
  readMinutes: number;
  visibility: 'public' | 'private';
  authorId: ObjectId | null;
  createdAt: Date;
  updatedAt: Date;
}

export interface StashItem {
  kind: 'lesson' | 'card';
  refId: string;
  addedAt: Date;
}

export interface StashDoc {
  _id: ObjectId;
  userId: ObjectId;
  name: string;
  icon: string;
  items: StashItem[];
  createdAt: Date;
  updatedAt: Date;
}

export interface Collections {
  users: Collection<UserDoc>;
  sessions: Collection<SessionDoc>;
  lessons: Collection<LessonDoc>;
  stashes: Collection<StashDoc>;
}

let clientPromise: Promise<MongoClient> | null = null;
let ready: Promise<void> | null = null;

/** Cached across warm serverless invocations. */
export async function getDb(): Promise<Db> {
  if (!clientPromise) {
    const uri = process.env.MONGODB_URI;
    if (!uri) throw new Error('MONGODB_URI is not set');
    clientPromise = new MongoClient(uri, { maxPoolSize: 10, serverSelectionTimeoutMS: 10_000 })
      .connect()
      .catch((e) => {
        clientPromise = null;
        throw e;
      });
  }
  const db = (await clientPromise).db(process.env.MONGODB_DB || 'kernel');
  if (!ready) {
    ready = ensureIndexes(db).catch((e) => {
      ready = null;
      throw e;
    });
  }
  await ready;
  return db;
}

export async function cols(): Promise<Collections> {
  const db = await getDb();
  return {
    users: db.collection<UserDoc>('users'),
    sessions: db.collection<SessionDoc>('sessions'),
    lessons: db.collection<LessonDoc>('lessons'),
    stashes: db.collection<StashDoc>('stashes'),
  };
}

export async function closeDb(): Promise<void> {
  if (clientPromise) await (await clientPromise).close();
  clientPromise = null;
  ready = null;
}

async function ensureIndexes(db: Db): Promise<void> {
  await Promise.all([
    db.collection('users').createIndex({ email: 1 }, { unique: true }),
    db.collection('sessions').createIndex({ tokenHash: 1 }, { unique: true }),
    db.collection('sessions').createIndex({ userId: 1 }),
    db.collection('sessions').createIndex({ expiresAt: 1 }, { expireAfterSeconds: 0 }),
    db.collection('lessons').createIndex({ slug: 1 }, { unique: true }),
    db.collection('lessons').createIndex({ visibility: 1, topic: 1, createdAt: -1 }),
    db.collection('lessons').createIndex({ authorId: 1 }),
    db.collection('lessons').createIndex({ 'cards.id': 1 }),
    db.collection('stashes').createIndex({ userId: 1, createdAt: 1 }),
  ]);
}
