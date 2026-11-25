import type { CardType } from '../db.js';

export interface SeedLesson {
  slug: string;
  title: string;
  summary: string;
  topic: string;
  source: string;
  author: string;
  takeaways: string[];
  cards: { type: CardType; title: string; body: string }[];
  /** Markdown. */
  body: string;
}
