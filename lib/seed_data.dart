// Seed library. Each card is an original, short summary of a well-known idea,
// credited to the book or thinker it comes from.
import 'models.dart';

const topics = <Topic>[
  Topic('psychology', 'Psychology', '🧠'),
  Topic('productivity', 'Productivity', '⚡'),
  Topic('habits', 'Habits', '🔁'),
  Topic('leadership', 'Leadership', '🧭'),
  Topic('ai', 'AI & Tech', '🤖'),
  Topic('money', 'Money', '💰'),
  Topic('health', 'Health', '🌿'),
  Topic('communication', 'Communication', '💬'),
];

Topic topicById(String id) =>
    topics.firstWhere((t) => t.id == id, orElse: () => const Topic('other', 'Other', '✨'));

IdeaCard _c(String id, String topic, CardType type, String title, String body,
        String source, String author) =>
    IdeaCard(id: id, topic: topic, type: type, title: title, body: body, source: source, author: author);

const _i = CardType.idea, _q = CardType.quote, _t = CardType.tip;

final seedCards = <IdeaCard>[
  // Psychology
  _c('p1', 'psychology', _i, 'Two systems of thinking',
      'Fast thinking is automatic, intuitive and effortless. Slow thinking is deliberate and tiring. Most errors come from letting the fast system answer a question that needed the slow one.',
      'Thinking, Fast and Slow', 'Daniel Kahneman'),
  _c('p2', 'psychology', _i, 'Loss aversion',
      'A loss feels roughly twice as painful as an equal gain feels good. That\'s why we hold losing investments too long and why free trials that "take away" features are so persuasive.',
      'Prospect Theory', 'Kahneman & Tversky'),
  _c('p3', 'psychology', _t, 'Name the emotion to tame it',
      'Putting a feeling into words ("I\'m anxious about this deadline") measurably reduces its intensity. Labeling shifts activity from alarm to reasoning.',
      'Affect labeling research', 'Matthew Lieberman'),
  _c('p4', 'psychology', _q, 'On the space between',
      'Between stimulus and response there is a space. In that space is our power to choose our response.',
      'Attributed', 'Viktor Frankl'),
  _c('p5', 'psychology', _i, 'Growth mindset',
      'People who see ability as something built through effort seek challenges and recover from failure faster than those who see it as fixed. Praise the process, not the talent.',
      'Mindset', 'Carol Dweck'),

  // Productivity
  _c('pr1', 'productivity', _i, 'Deep work is rare and valuable',
      'Distraction-free focus on cognitively demanding tasks produces your best output. Because it\'s increasingly rare, it\'s also increasingly valuable. Schedule it like a meeting.',
      'Deep Work', 'Cal Newport'),
  _c('pr2', 'productivity', _t, 'The two-minute rule',
      'If a task takes less than two minutes, do it now. Tracking it costs more than finishing it.',
      'Getting Things Done', 'David Allen'),
  _c('pr3', 'productivity', _i, 'Urgent vs. important',
      'Sort tasks into four boxes by urgency and importance. The important-but-not-urgent box — planning, learning, relationships — is where long-term results come from, and it\'s the first one we neglect.',
      'The Eisenhower Matrix', 'popularized by Stephen Covey'),
  _c('pr4', 'productivity', _i, 'Parkinson\'s Law',
      'Work expands to fill the time available. Tighter, self-imposed deadlines often produce the same quality in far less time.',
      'Parkinson\'s Law', 'C. Northcote Parkinson'),
  _c('pr5', 'productivity', _t, 'Eat the frog',
      'Do your hardest, most dreaded task first thing. Everything after it feels easier, and you stop spending energy avoiding it.',
      'Eat That Frog!', 'Brian Tracy'),

  // Habits
  _c('h1', 'habits', _i, 'Systems beat goals',
      'Winners and losers often share the same goals. What separates them is the system — the daily process. Fall in love with the process and results follow.',
      'Atomic Habits', 'James Clear'),
  _c('h2', 'habits', _i, 'The habit loop',
      'Every habit runs on cue → routine → reward. To change a habit, keep the cue and the reward but swap in a new routine.',
      'The Power of Habit', 'Charles Duhigg'),
  _c('h3', 'habits', _t, 'Make it tiny',
      'Shrink a new habit until it\'s almost too easy: one push-up, one sentence, one minute. Consistency comes first; size comes later.',
      'Tiny Habits', 'BJ Fogg'),
  _c('h4', 'habits', _t, 'Habit stacking',
      'Attach a new habit to an existing one: "After I pour my coffee, I\'ll write down one priority for the day." The old habit becomes the cue.',
      'Atomic Habits', 'James Clear'),
  _c('h5', 'habits', _i, 'Identity-based habits',
      'Instead of "I want to run a marathon," try "I\'m a runner." Each action becomes a vote for the person you want to be.',
      'Atomic Habits', 'James Clear'),

  // Leadership
  _c('l1', 'leadership', _i, 'Start with why',
      'People don\'t buy what you do; they buy why you do it. Leaders who communicate purpose first inspire loyalty that features and prices can\'t.',
      'Start With Why', 'Simon Sinek'),
  _c('l2', 'leadership', _i, 'Psychological safety',
      'A strong predictor of team performance is whether people feel safe taking risks — admitting mistakes, asking questions, disagreeing — without being punished.',
      'The Fearless Organization', 'Amy Edmondson'),
  _c('l3', 'leadership', _t, 'Radical candor',
      'Care personally and challenge directly at the same time. Feedback without care is aggression; care without challenge is ruinous empathy.',
      'Radical Candor', 'Kim Scott'),
  _c('l4', 'leadership', _q, 'On extreme ownership',
      'There are no bad teams, only bad leaders.',
      'Extreme Ownership', 'Jocko Willink & Leif Babin'),
  _c('l5', 'leadership', _i, 'Disagree and commit',
      'Debate fully, then once a decision is made, commit to it wholeheartedly — even if you argued against it. Teams move faster than when every decision needs unanimity.',
      'Management practice', 'Andy Grove'),

  // AI & Tech
  _c('a1', 'ai', _i, 'Models predict, they don\'t know',
      'Language models generate the most plausible next words given their training. That makes them fluent but not automatically correct — verify facts that matter.',
      'How LLMs work', 'General principle'),
  _c('a2', 'ai', _t, 'Give context, not just commands',
      'AI assistants do better when you explain the goal, audience and constraints, not just the task. "Summarize this for a busy executive deciding on budget" beats "summarize this."',
      'Prompting practice', 'General principle'),
  _c('a3', 'ai', _i, 'Amara\'s Law',
      'We tend to overestimate the effect of a technology in the short run and underestimate it in the long run.',
      'Amara\'s Law', 'Roy Amara'),
  _c('a4', 'ai', _i, 'Centaurs and cyborgs',
      'People using AI well tend to either divide work cleanly between themselves and the tool, or weave it tightly into every step. Both beat using it blindly or not at all.',
      'Co-Intelligence', 'Ethan Mollick'),

  // Money
  _c('m1', 'money', _i, 'Pay yourself first',
      'Save a fixed share of income the moment it arrives, before spending anything. Automating it removes willpower from the equation.',
      'The Richest Man in Babylon', 'George S. Clason'),
  _c('m2', 'money', _i, 'Compounding needs time',
      'Most of Warren Buffett\'s wealth was earned after age 65 — not because he got better, but because compounding had decades to work. Starting early matters more than starting big.',
      'The Psychology of Money', 'Morgan Housel'),
  _c('m3', 'money', _t, 'The 30-day rule',
      'For non-essential purchases, wait 30 days. If you still want it, buy it. Most impulse wants fade.',
      'Personal finance practice', 'General principle'),
  _c('m4', 'money', _q, 'On enough',
      'The hardest financial skill is getting the goalpost to stop moving.',
      'The Psychology of Money', 'Morgan Housel'),

  // Health
  _c('he1', 'health', _i, 'Sleep is the foundation',
      'Sleep consolidates memory, regulates mood and repairs the body. Consistently getting under seven hours undermines nearly every other health habit.',
      'Why We Sleep', 'Matthew Walker'),
  _c('he2', 'health', _t, 'Zone 2 cardio',
      'Exercise at a pace where you can still hold a conversation. A few hours a week builds aerobic base and metabolic health with little injury risk.',
      'Outlive', 'Peter Attia'),
  _c('he3', 'health', _t, 'Morning light',
      'Getting outdoor light within an hour of waking helps set your circadian rhythm, improving alertness by day and sleep at night.',
      'Circadian research', 'General principle'),
  _c('he4', 'health', _i, 'Walking boosts creativity',
      'People generate noticeably more creative ideas while walking than while sitting. Stuck on a problem? Take it for a walk.',
      'Stanford study (2014)', 'Oppezzo & Schwartz'),

  // Communication
  _c('c1', 'communication', _t, 'Listen to understand',
      'Most people listen with the intent to reply. Try summarizing the other person\'s point back to them before giving yours — conflicts shrink fast.',
      'The 7 Habits of Highly Effective People', 'Stephen Covey'),
  _c('c2', 'communication', _t, 'Tactical empathy',
      'Label the other side\'s feelings ("It seems like you\'re worried about timing"). Feeling understood lowers defenses and opens negotiation.',
      'Never Split the Difference', 'Chris Voss'),
  _c('c3', 'communication', _i, 'Lead with the bottom line',
      'State your conclusion first, then the supporting points. Busy readers decide in the first two sentences whether to keep reading.',
      'The Pyramid Principle', 'Barbara Minto'),
  _c('c4', 'communication', _i, 'People remember how you made them feel',
      'Making someone feel heard and important — using their name, showing genuine interest — is remembered long after what you said is forgotten.',
      'How to Win Friends and Influence People', 'Dale Carnegie'),
];
