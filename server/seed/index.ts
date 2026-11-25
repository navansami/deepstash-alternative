import { ObjectId } from 'mongodb';

import { cols, type LessonDoc } from '../db.js';
import { readMinutes } from '../routes/lessons.js';
import { lessonsA } from './lessons-a.js';
import { lessonsB } from './lessons-b.js';

export const seedLessons = [...lessonsA, ...lessonsB];

/**
 * Upserts the built-in lessons by slug. Safe to run repeatedly: existing seed lessons are
 * updated in place (keeping their _id, so stashes and progress survive) and user content is untouched.
 */
export async function runSeed(): Promise<{ inserted: number; updated: number }> {
  const { lessons } = await cols();
  let inserted = 0;
  let updated = 0;
  const now = new Date();
  for (const s of seedLessons) {
    const fields: Omit<LessonDoc, '_id' | 'createdAt'> = {
      slug: s.slug,
      title: s.title,
      summary: s.summary,
      topic: s.topic,
      source: s.source,
      author: s.author,
      body: s.body.trim(),
      takeaways: s.takeaways,
      cards: s.cards.map((c, i) => ({ ...c, id: `${s.slug}-${i + 1}` })),
      readMinutes: readMinutes(s.body),
      visibility: 'public',
      authorId: null,
      updatedAt: now,
    };
    const r = await lessons.updateOne(
      { slug: s.slug },
      { $set: fields, $setOnInsert: { _id: new ObjectId(), createdAt: now } },
      { upsert: true },
    );
    if (r.upsertedCount) inserted++;
    else if (r.modifiedCount) updated++;
  }
  return { inserted, updated };
}
