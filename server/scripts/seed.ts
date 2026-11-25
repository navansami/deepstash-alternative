// Usage: npm run seed   (upserts built-in lessons into the database in MONGODB_URI)
import { closeDb } from '../db.js';
import { runSeed, seedLessons } from '../seed/index.js';

const r = await runSeed();
console.log(`Seeded ${seedLessons.length} lessons: ${r.inserted} inserted, ${r.updated} updated.`);
await closeDb();
