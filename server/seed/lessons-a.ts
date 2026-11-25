import type { SeedLesson } from './types.js';

// Psychology, Productivity, Habits, Leadership.
// Original summaries written for this app, crediting the books and thinkers they draw on.
export const lessonsA: SeedLesson[] = [
  {
    slug: 'two-systems-of-thinking',
    title: 'Two Systems: How Your Mind Really Decides',
    summary: 'Why quick intuition and slow reasoning both matter, and how to tell which one is answering.',
    topic: 'psychology',
    source: 'Thinking, Fast and Slow',
    author: 'Daniel Kahneman',
    takeaways: [
      'Fast thinking (System 1) is automatic and always on; slow thinking (System 2) is effortful and lazy.',
      'Most errors happen when System 1 answers an easier question than the one you were asked.',
      'Slow down for decisions that are high-stakes, unfamiliar, or where you feel unusually certain.',
      'Checklists, base rates and a second opinion are ways of borrowing System 2 when you need it.',
    ],
    cards: [
      { type: 'idea', title: 'Two systems of thinking', body: 'Fast thinking is automatic, intuitive and effortless. Slow thinking is deliberate and tiring. Most errors come from letting the fast system answer a question that needed the slow one.' },
      { type: 'idea', title: 'Question substitution', body: 'Faced with a hard question ("Will this hire succeed?"), the mind quietly answers an easier one ("Did I like them?") and never notices the swap.' },
      { type: 'tip', title: 'Distrust easy certainty', body: 'When an answer arrives instantly and feels obviously right on an important decision, treat that as a cue to slow down, not to speed up.' },
    ],
    body: `Daniel Kahneman's research, much of it with Amos Tversky, describes the mind as two cooperating characters. The labels are shorthand rather than brain regions, but they are a useful way to notice how you actually think.

## System 1: fast, automatic, always on

System 1 reads faces, completes "bread and..." before you can stop it, and swerves the car before you consciously see the hazard. It works by association and pattern-matching. It is quick, effortless and usually right, which is why we trust it.

Its weakness is that it is built for coherence, not accuracy. It takes whatever information is in front of it and builds the most plausible story, without asking what is missing. Kahneman calls this *what you see is all there is*.

## System 2: slow, effortful, lazy

System 2 is what you use to multiply 17 by 24, compare two mortgage offers, or check an argument for holes. It can follow rules and weigh evidence, but it is tiring to run, so it tends to accept whatever System 1 suggests unless something clearly looks wrong.

That laziness is the key. System 2 is not a referee that checks every call. Most of the time it signs off on System 1's answers without reading them.

## Where it goes wrong

Many classic thinking errors follow the same pattern: System 1 produces a quick, confident answer and System 2 doesn't step in.

- **Substitution.** A hard question gets quietly swapped for an easier one. "How happy are you with your life?" becomes "What's my mood right now?"
- **Anchoring.** An arbitrary number seen first, such as an asking price, pulls later estimates towards it.
- **Availability.** We judge how common something is by how easily examples come to mind, so vivid news stories distort our sense of risk.

## Working with both systems

You can't switch System 1 off, and you wouldn't want to. The goal is to recognise the situations where it is likely to mislead you:

1. **High stakes.** Hiring, investing and medical choices deserve deliberate effort.
2. **Unfamiliar territory.** Intuition is only reliable where you have had lots of practice with quick, honest feedback.
3. **Strong certainty.** Feeling sure is a property of the story, not evidence that the story is true.

In those moments, borrow System 2 on purpose. Write down the question you are actually answering. Look up the base rate: how often does this kind of thing usually work out? Ask someone who doesn't share your first impression. Use a checklist, which is simply System 2 thinking done once in advance.

Good judgment isn't about never trusting your gut. It's about knowing when your gut is an expert and when it's guessing.`,
  },
  {
    slug: 'loss-aversion',
    title: 'Loss Aversion: Why Losing Hurts Twice as Much',
    summary: 'The asymmetry between gains and losses quietly shapes how we invest, negotiate and change.',
    topic: 'psychology',
    source: 'Prospect Theory',
    author: 'Daniel Kahneman & Amos Tversky',
    takeaways: [
      'Losses are felt more strongly than equal gains, often by a factor of around two.',
      'Framing the same choice as a loss or a gain can flip what people decide.',
      'Loss aversion fuels the endowment effect, status-quo bias and holding losing investments too long.',
      'Reframe decisions in terms of the overall outcome, not the pain of giving something up.',
    ],
    cards: [
      { type: 'idea', title: 'Loss aversion', body: 'A loss feels roughly twice as painful as an equal gain feels good. That is why we hold losing investments too long and why free trials that "take away" features are so persuasive.' },
      { type: 'idea', title: 'The endowment effect', body: 'Once we own something, we value it more than we would pay to get it. Giving it up registers as a loss, not a forgone gain.' },
      { type: 'tip', title: 'Use the "would I buy it today?" test', body: 'For anything you are reluctant to let go of, such as a stock, a project or a subscription, ask whether you would choose it today if you didn\'t already have it.' },
    ],
    body: `In 1979 Daniel Kahneman and Amos Tversky published prospect theory, a description of how people actually make decisions under risk. One of its central findings is simple to state and surprisingly far-reaching: **losses loom larger than gains.**

## The asymmetry

Offer people a coin flip where they lose $100 on tails, and most want to win at least $150 to $250 on heads before they'll accept. Losing $100 hurts more than winning $100 feels good. Estimates vary between studies and situations, but a ratio of around two to one is a common rule of thumb.

The effect isn't limited to money. It shows up with time, status, possessions and even ideas we have committed to.

## Framing changes choices

Because losses and gains feel different, the same facts described differently can change decisions. In a famous experiment, people were told about a disease expected to kill 600 people and offered two programmes. Described as "200 people will be saved", the safe option was popular. Described as "400 people will die", people preferred the risky gamble, even though the outcomes were identical.

We tend to avoid risk when protecting gains and seek risk when trying to avoid losses.

## Where you'll see it

- **The endowment effect.** In classic experiments, people given a mug asked for roughly twice as much to sell it as others would pay to buy it.
- **Status-quo bias.** Changing anything means giving up the current option, and that registers as a loss. Default choices are powerful for this reason.
- **Holding losers.** Investors often keep falling stocks to avoid "making the loss real", and sell rising stocks too early to lock in the gain.
- **Marketing.** "Don't miss out", expiring discounts and free trials that remove features at the end all lean on the pain of losing.

## Making better decisions

Loss aversion isn't irrational in every case. Avoiding ruin matters more than chasing upside. The trouble comes when it makes us refuse good bets or cling to bad positions.

A few practical habits help:

1. **Zoom out.** Evaluate a decision as one of many similar ones. A single small loss feels terrible, but a portfolio of favourable bets wins over time.
2. **Ask the fresh-start question.** "If I didn't already own this, would I buy it today at this price?" The answer often makes the decision obvious.
3. **Reframe both ways.** Before deciding, describe the choice as a gain and as a loss. If your preference flips, the framing is doing the work, not the facts.
4. **Set rules in advance.** Decide your exit points before emotions are involved.

Noticing the sting of a loss doesn't make it go away. But it does let you ask whether the sting is information or just noise.`,
  },
  {
    slug: 'deep-work',
    title: 'Deep Work: Focus as a Competitive Advantage',
    summary: 'Why long, undistracted concentration produces your best work, and how to build it into your week.',
    topic: 'productivity',
    source: 'Deep Work',
    author: 'Cal Newport',
    takeaways: [
      'Deep work is focused effort on demanding tasks; shallow work is easy, interruptible and easy to copy.',
      'Every switch of attention leaves "attention residue" that lowers the quality of what comes next.',
      'Schedule deep work in blocks and protect them the way you would a meeting.',
      'Focus is a trainable skill: practise boredom instead of reaching for your phone at every pause.',
    ],
    cards: [
      { type: 'idea', title: 'Deep work is rare and valuable', body: 'Distraction-free focus on cognitively demanding tasks produces your best output. Because it is increasingly rare, it is also increasingly valuable. Schedule it like a meeting.' },
      { type: 'idea', title: 'Attention residue', body: 'When you switch tasks, part of your attention stays with the previous one. Quick email checks during focused work quietly lower its quality.' },
      { type: 'tip', title: 'Embrace boredom', body: 'If you reach for your phone at every queue and pause, your brain learns to expect constant novelty. Let yourself be bored sometimes so focus stays possible.' },
      { type: 'tip', title: 'Shut down on purpose', body: 'End the workday with a short ritual: review open tasks, plan tomorrow, then declare yourself done. It frees your mind to actually rest.' },
    ],
    body: `Cal Newport defines **deep work** as professional activity done in a state of distraction-free concentration that pushes your abilities to their limit. **Shallow work** is the opposite: logistical, low-focus tasks done while distracted, such as most email, status updates and quick messages.

Newport's argument is that deep work is becoming both more valuable and rarer at the same time. Whoever can still do it has an advantage.

## Why depth matters

Two abilities matter in a changing economy: learning hard things quickly, and producing high-quality work. Both depend on sustained focus. Learning complex material requires concentrating without interruption, and producing excellent work is roughly *time spent × intensity of focus*.

## The cost of switching

Research by Sophie Leroy describes **attention residue**. When you move from task A to task B, part of your mind keeps thinking about A, and performance on B suffers. A "quick look" at your inbox in the middle of writing doesn't cost thirty seconds. It costs the next twenty minutes of sharp thinking.

An open-plan, always-connected workday can feel productive because you're busy all the time, but busyness isn't the same as output.

## Building deep work into your week

Newport describes several approaches. Choose the one your job allows:

- **Monastic.** Remove shallow obligations almost entirely. This is rare and suits some writers and researchers.
- **Bimodal.** Alternate whole days or weeks of depth with periods that are open to everyone.
- **Rhythmic.** A fixed deep-work block at the same time every day. This is the easiest to sustain.
- **Journalistic.** Switch into depth whenever a gap appears. This takes practice.

Whichever you choose, add rituals that make focus easier: a set place, a start time, a clear goal for the session, and rules such as no internet or phone in another room.

## Train your attention

Concentration works like a muscle, and constant distraction weakens it. If every idle moment is filled with a feed, your brain comes to expect novelty and resists sustained effort. Newport's advice is to **embrace boredom**: schedule specific times for internet use and stay offline outside them, rather than the other way round.

## Protect the edges

Make shallow work deliberate. Batch email at set times, and ask whether each recurring meeting needs you. Then finish the day with a shutdown ritual: capture loose ends, plan tomorrow, and mark yourself done. Rest isn't time off from deep work. It is what makes tomorrow's deep work possible.`,
  },
  {
    slug: 'urgent-vs-important',
    title: 'Urgent vs. Important: The Eisenhower Matrix',
    summary: 'A simple four-box grid that shows where your time goes and where it should go.',
    topic: 'productivity',
    source: 'The 7 Habits of Highly Effective People',
    author: 'Stephen Covey (after Dwight Eisenhower)',
    takeaways: [
      'Urgent means it demands attention now; important means it contributes to your goals.',
      'The "important but not urgent" quadrant drives long-term results and is the first to be neglected.',
      'Delegate urgent-but-unimportant work where you can, and cut unimportant, non-urgent work ruthlessly.',
      'Plan your week around important commitments before the urgent ones fill it.',
    ],
    cards: [
      { type: 'idea', title: 'Urgent vs. important', body: 'Sort tasks into four boxes by urgency and importance. The important-but-not-urgent box (planning, learning, relationships) is where long-term results come from, and it is the first one we neglect.' },
      { type: 'tip', title: 'Big rocks first', body: 'Put your most important commitments into your calendar before the week starts. Smaller tasks will fit around them; the reverse rarely works.' },
      { type: 'quote', title: 'On the two kinds of problems', body: 'What is important is seldom urgent and what is urgent is seldom important.' },
    ],
    body: `Dwight Eisenhower, a general and later a US president, is often credited with the line "what is important is seldom urgent and what is urgent is seldom important." Stephen Covey turned the idea into a grid in *The 7 Habits of Highly Effective People*, and it remains one of the simplest prioritisation tools there is.

## Two questions

For any task, ask:

1. **Is it urgent?** Does it demand attention now, with a deadline or someone waiting?
2. **Is it important?** Does it contribute meaningfully to your goals, values or responsibilities?

Urgency is about time pressure. Importance is about consequence. We tend to react to urgency and lose sight of importance.

## The four quadrants

**Quadrant 1: urgent and important.** Crises, real deadlines, a sick child. These must be done. A life lived mostly here is exhausting, and much of Q1 is Q2 work that was neglected until it turned into a crisis.

**Quadrant 2: important, not urgent.** Planning, learning, exercise, relationships, preventive maintenance, building systems. Nothing forces you to do these today, which is exactly why they slip. Covey argues this quadrant is the heart of effective personal management.

**Quadrant 3: urgent, not important.** Many interruptions, some meetings, other people's minor priorities. They *feel* important because they're pressing. Delegate, batch or decline them where you can.

**Quadrant 4: neither.** Mindless scrolling, busywork, escape activities. Some rest is valuable, but deliberate rest is different from drifting. Cut back here first.

## Making Q2 real

Knowing about the grid changes little unless Q2 work actually gets time. A few practical moves:

- **Plan weekly, not just daily.** Each week, choose two or three important outcomes and block time for them first. Covey compares this to putting the big rocks in a jar before the sand.
- **Treat Q2 blocks as appointments.** If someone asked for that time, you could say "I'm booked", because you are.
- **Track a week honestly.** Label where your hours actually went. Most people are surprised by how much falls into Q3.
- **Prevent future Q1.** Each recurring crisis is a hint about Q2 work that would stop it happening again.

## A caution

The matrix is a lens, not a law. Some urgent tasks matter more than they look, and some "important" projects are vanity. Use it to ask a better question each morning: *what would move things forward, rather than just keep up?*`,
  },
  {
    slug: 'systems-over-goals',
    title: 'Atomic Habits: Systems Over Goals',
    summary: 'Small changes, repeated, compound into remarkable results. Here is how to design them.',
    topic: 'habits',
    source: 'Atomic Habits',
    author: 'James Clear',
    takeaways: [
      'Goals set direction; systems (your daily processes) determine progress.',
      'Small improvements compound: 1% better each day adds up dramatically over a year.',
      'Make good habits obvious, attractive, easy and satisfying, and invert those for bad habits.',
      'The deepest change is identity: each action is a vote for who you want to become.',
    ],
    cards: [
      { type: 'idea', title: 'Systems beat goals', body: 'Winners and losers often share the same goals. What separates them is the system, the daily process. Fall in love with the process and results follow.' },
      { type: 'tip', title: 'Habit stacking', body: 'Attach a new habit to an existing one: "After I pour my coffee, I\'ll write down one priority for the day." The old habit becomes the cue.' },
      { type: 'idea', title: 'Identity-based habits', body: 'Instead of "I want to run a marathon", try "I\'m a runner". Each action becomes a vote for the person you want to be.' },
      { type: 'tip', title: 'The two-minute version', body: 'Scale any new habit down to something that takes two minutes: "read one page", "put on running shoes". Master showing up before you optimise.' },
    ],
    body: `James Clear's *Atomic Habits* starts from a simple observation: you do not rise to the level of your goals, you fall to the level of your systems.

## Why goals aren't enough

Every competitor in a race wants to win. Every start-up wants to succeed. Since winners and losers often share the same goals, the goal can't be what separates them. The difference is the **system**: the repeated, everyday processes that produce results.

Goals have other problems too. Reaching one is only a momentary change. Goals can delay happiness ("I'll be happy when..."). And once a goal is reached, the behaviour that got you there often stops. A system keeps working.

## The maths of small changes

If you get 1% better each day for a year, you end up about 37 times better. If you get 1% worse each day, you decline to almost nothing. The numbers are illustrative rather than literal, but the point holds: habits compound. Their effects are invisible at first, which is why people give up during the "plateau of latent potential" before results show.

## The four laws of behaviour change

Clear organises habit design around four laws. Invert each one to break a bad habit.

1. **Make it obvious.** Put the cue in plain sight: the book on your pillow, the water bottle on your desk. Use implementation intentions ("I will [behaviour] at [time] in [place]") and habit stacking ("After [current habit], I will [new habit]").
2. **Make it attractive.** Pair a habit you need with one you enjoy, such as listening to a favourite podcast only while exercising. Spend time around people for whom the habit is normal.
3. **Make it easy.** Reduce friction. Prepare the gym bag the night before. Use the **two-minute rule**: start with a version so small it's hard to say no to.
4. **Make it satisfying.** Behaviours that are rewarded get repeated. Track habits visibly and don't break the chain. If you miss once, never miss twice.

To break a habit: make it invisible, unattractive, difficult and unsatisfying. Leave the phone in another room, and add a cost or an accountability partner.

## Identity is the real target

The deepest level of change is identity. "I'm trying to quit smoking" and "I'm not a smoker" lead to different behaviour. Every time you write, you cast a vote for being a writer. No single vote decides it, but the votes add up.

So start with who you want to become, then prove it to yourself with small wins. The habit is the evidence.`,
  },
  {
    slug: 'the-habit-loop',
    title: 'The Habit Loop: Cue, Routine, Reward',
    summary: 'How habits form in the brain, and the "golden rule" for changing the ones you don\'t want.',
    topic: 'habits',
    source: 'The Power of Habit',
    author: 'Charles Duhigg',
    takeaways: [
      'Habits run on a loop: a cue triggers a routine, which delivers a reward.',
      'Over time the brain starts craving the reward as soon as it sees the cue.',
      'To change a habit, keep the cue and reward but deliberately swap the routine.',
      'Experiment to find the real reward. It is often not what you assume.',
    ],
    cards: [
      { type: 'idea', title: 'The habit loop', body: 'Every habit runs on cue, routine, reward. To change a habit, keep the cue and the reward but swap in a new routine.' },
      { type: 'tip', title: 'Find the real reward', body: 'Craving a 3pm cookie? Try a walk, a chat or an apple instead. Whichever kills the urge reveals what you actually wanted: rest, company or sugar.' },
      { type: 'idea', title: 'Keystone habits', body: 'Some habits, like regular exercise or family dinners, spill over and make other good behaviours easier. Start with those.' },
    ],
    body: `Charles Duhigg's *The Power of Habit* popularised research showing that a large share of our daily actions aren't decisions at all. They are habits, running on autopilot so the brain can save effort.

## The three-step loop

Researchers studying the basal ganglia, a brain region involved in habits, found a consistent pattern:

1. **Cue.** A trigger that tells the brain to go into automatic mode. Cues tend to fall into a few categories: location, time, emotional state, other people, or an immediately preceding action.
2. **Routine.** The behaviour itself, whether physical, mental or emotional.
3. **Reward.** Something that helps the brain decide whether this loop is worth remembering.

Repeat the loop often enough and it becomes automatic. Brain activity during the routine drops, and you can do it while thinking about something else entirely.

## Cravings drive the loop

What makes a habit powerful is **anticipation**. Over time, the brain starts expecting the reward as soon as it sees the cue, and that expectation creates a craving. The smell of a bakery, a phone buzzing in your pocket: the craving arrives before the routine starts, and resisting it feels like losing something.

## The golden rule of habit change

You rarely get rid of a bad habit by simply stopping it. Duhigg's golden rule is to **keep the old cue and the old reward, and insert a new routine**.

The difficult part is diagnosing the loop, which takes some detective work:

- **Identify the routine.** Say it's an afternoon trip to the café for a cookie.
- **Experiment with rewards.** On different days, replace the trip with a walk, a chat with a colleague, or an apple at your desk. After each, wait fifteen minutes. Is the urge gone? That tells you what the reward really was, whether movement, company or sugar.
- **Isolate the cue.** When the urge hits, note the location, time, emotional state, who's around, and what you just did. A pattern usually appears quickly. Perhaps it's always around 3:30pm.
- **Make a plan.** "At 3:30, I will walk to a friend's desk and talk for ten minutes." Write it down and repeat it until it's automatic.

## Belief and keystone habits

Duhigg also points to two accelerators. **Belief** that change is possible, often strengthened by a group, helps habits hold under stress. And **keystone habits**, such as exercise, making the bed or regular family dinners, tend to set off chain reactions in other areas of life.

Habits aren't destiny. Once you can see the loop, you can redesign it.`,
  },
  {
    slug: 'psychological-safety',
    title: 'Psychological Safety: The Foundation of Great Teams',
    summary: 'Teams learn and perform better when people can speak up without fear. Leaders can create that.',
    topic: 'leadership',
    source: 'The Fearless Organization',
    author: 'Amy Edmondson',
    takeaways: [
      'Psychological safety is a shared belief that the team is safe for interpersonal risk-taking.',
      'It is not about being nice or lowering standards; high safety and high standards work together.',
      'Leaders build it by framing work as learning, admitting fallibility and responding well to bad news.',
      'How you react to the first mistake or question you hear sets the norm for everyone else.',
    ],
    cards: [
      { type: 'idea', title: 'Psychological safety', body: 'A strong predictor of team performance is whether people feel safe taking risks (admitting mistakes, asking questions, disagreeing) without being punished.' },
      { type: 'idea', title: 'Safety is not comfort', body: 'Psychological safety plus high standards produces learning. Safety without standards drifts into complacency; standards without safety breed anxiety and silence.' },
      { type: 'tip', title: 'Respond productively', body: 'When someone brings a mistake or bad news, thank them first. Your reaction to the first messenger decides whether there will be a second.' },
    ],
    body: `In the 1990s, Amy Edmondson was studying hospital teams and expected the best teams to make the fewest medication errors. She found the opposite: better teams *reported* more errors. They weren't making more mistakes. They were more willing to talk about them.

She called the underlying factor **psychological safety**: a shared belief that the team is safe for interpersonal risk-taking. Google's later Project Aristotle, a study of what made its teams effective, found psychological safety to be the most important factor among those it examined.

## What it is, and isn't

Psychological safety means people feel able to ask a "naive" question, admit a mistake, flag a risk or disagree with the boss without fearing embarrassment or punishment.

It does **not** mean:

- Everyone is always nice or agrees.
- Performance standards are lowered.
- People are protected from consequences for poor work.

Edmondson pairs safety with accountability. High safety and high standards together produce a *learning zone*. Low safety with high standards produces an *anxiety zone*, where people work hard but hide problems. High safety with low standards becomes a comfort zone.

## Why it matters

Modern work is uncertain and interdependent. Problems are rarely spotted by one person alone, so what matters is whether whoever sees a problem says so. Silence is the default. Nobody gets fired for not speaking up, so the risks of speaking feel personal and immediate while the benefits seem distant.

## How leaders build it

Edmondson describes three moves:

**1. Set the stage.** Frame the work as a learning problem rather than an execution problem: "We've never done this before, we will hit surprises, and I need to hear about them early." Make clear why voices matter.

**2. Invite participation.** Admit your own fallibility ("I may be missing something"). Ask real questions rather than leading ones ("What are we not seeing?" rather than "Everyone agrees, right?"). Create structures, such as rounds where everyone speaks or anonymous input, that make speaking up easier.

**3. Respond productively.** This is where safety is won or lost. When someone raises a concern or reports a failure, express appreciation first, then look forward: "What do we do now?" Separate blameworthy acts, which are rare, from honest mistakes and well-designed experiments that didn't work.

## Start small

You can't announce psychological safety into existence. It builds through many small moments in which people take a risk and find nothing bad happens. Ask one more open question in your next meeting. Thank the next person who brings you bad news.`,
  },
  {
    slug: 'radical-candor',
    title: 'Radical Candor: Care Personally, Challenge Directly',
    summary: 'A practical framework for feedback that is both kind and clear.',
    topic: 'leadership',
    source: 'Radical Candor',
    author: 'Kim Scott',
    takeaways: [
      'Good feedback combines caring personally with challenging directly.',
      'Ruinous empathy, caring but not challenging, is the most common failure mode.',
      'Ask for criticism before you give it, and show that you welcome it.',
      'Praise and criticism should be specific, sincere, timely and given in private for criticism.',
    ],
    cards: [
      { type: 'tip', title: 'Radical candor', body: 'Care personally and challenge directly at the same time. Feedback without care is aggression; care without challenge is ruinous empathy.' },
      { type: 'idea', title: 'Ruinous empathy', body: 'Holding back criticism to spare someone\'s feelings feels kind, but it denies them the chance to improve. It is the most common way managers fail.' },
      { type: 'tip', title: 'Get feedback first', body: 'Before giving criticism, ask for it: "What could I do or stop doing that would make it easier to work with me?" Then wait through the silence.' },
    ],
    body: `Kim Scott developed *Radical Candor* from her experience managing teams at Google and Apple. The core idea fits on a simple two-axis chart.

## The two dimensions

- **Care personally:** you treat colleagues as whole people and care about their growth and lives, not just their output.
- **Challenge directly:** you tell people clearly when their work isn't good enough, when you disagree, or when there's something they need to hear.

Combining these gives four quadrants.

**Radical candor (cares, challenges).** "I want you to succeed, so I'm going to be clear: the presentation lost the audience in the middle. Here's what I noticed."

**Obnoxious aggression (challenges, doesn't care).** Brutal honesty without regard for the person. It's sometimes effective in the short term but corrosive over time.

**Ruinous empathy (cares, doesn't challenge).** "It was great!", while privately knowing it wasn't. Scott says this is the most common mistake. It feels kind, but it leaves people unaware of problems until it's too late, sometimes until they're fired.

**Manipulative insincerity (neither).** Flattery to someone's face and criticism behind their back, usually out of a desire to be liked or to avoid conflict.

Scott stresses that these describe *feedback*, not personalities. Everyone lands in each quadrant at times.

## How to practise it

**Get feedback before giving it.** Ask your team for criticism first, in an open way: "What's one thing I could do or stop doing that would make it easier to work with me?" Then stay quiet long enough for a real answer. Reward candour when you get it, or you won't get it again.

**Make it HIP: humble, helpful, immediate, in person (and private for criticism).**
- *Humble:* share your perspective as your view, not the truth.
- *Helpful:* the goal is to help them improve, not to show you're right.
- *Immediate:* small, quick conversations beat saved-up annual reviews.
- *In person:* tone matters, and text strips it away. Praise in public, criticise in private.

**Don't neglect praise.** Specific, sincere praise ("the way you restructured the data section made the decision obvious") tells people what to do more of. It is as important as criticism and usually more neglected.

**Address the work, not the personality.** "This report had three factual errors" is actionable. "You're careless" is not.

## Why it works

People rarely resent honest feedback from someone who clearly cares about them. They resent being surprised, humiliated or quietly sidelined. Radical candor builds trust because people know where they stand, and that makes better work possible.`,
  },
];
