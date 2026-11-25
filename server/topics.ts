export const TOPICS = [
  { id: 'psychology', name: 'Psychology' },
  { id: 'productivity', name: 'Productivity' },
  { id: 'habits', name: 'Habits' },
  { id: 'leadership', name: 'Leadership' },
  { id: 'ai', name: 'AI & Tech' },
  { id: 'money', name: 'Money' },
  { id: 'health', name: 'Health' },
  { id: 'communication', name: 'Communication' },
] as const;

export const TOPIC_IDS = TOPICS.map((t) => t.id) as [string, ...string[]];

/** Icon keys the client maps to real icons. Stored on stashes. */
export const STASH_ICONS = [
  'bookmark', 'star', 'lightbulb', 'target', 'brain', 'flame',
  'leaf', 'briefcase', 'heart', 'book',
] as const;
