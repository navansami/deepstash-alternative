import type { SeedLesson } from './types.js';

// AI & Tech, Money, Health, Communication.
export const lessonsB: SeedLesson[] = [
  {
    slug: 'how-language-models-work',
    title: 'How Language Models Work, and What That Means for You',
    summary: 'A plain-language look at what AI chat assistants are doing, so you can use them well.',
    topic: 'ai',
    source: 'How LLMs work',
    author: 'General principle',
    takeaways: [
      'Language models are trained to predict likely next words, which gives them broad, fluent knowledge.',
      'Fluency is not the same as accuracy. Models can state wrong things confidently.',
      'Clear context (goal, audience, constraints, examples) dramatically improves results.',
      'Verify facts that matter and keep a human responsible for the final decision.',
    ],
    cards: [
      { type: 'idea', title: 'Models predict, they don\'t "know"', body: 'Language models generate the most plausible continuation given their training. That makes them fluent but not automatically correct, so verify facts that matter.' },
      { type: 'tip', title: 'Give context, not just commands', body: 'AI assistants do better when you explain the goal, audience and constraints. "Summarise this for a busy executive deciding on budget" beats "summarise this".' },
      { type: 'tip', title: 'Show an example', body: 'If you want a particular format or tone, paste a short example of what good looks like. One example often beats a paragraph of description.' },
    ],
    body: `AI chat assistants can draft emails, explain concepts, write code and summarise documents. Knowing roughly how they work helps you use them well and avoid their pitfalls.

## Prediction at enormous scale

A large language model (LLM) is trained on a huge amount of text to do one thing: given some text, predict what comes next. It works with small chunks of text called tokens. To get very good at that, the model has to absorb a great deal about grammar, facts, reasoning patterns, styles and how ideas relate.

Further training, often using human feedback, then shapes the model into a helpful assistant that follows instructions, declines harmful requests and admits uncertainty more often.

The result can feel like talking to a well-read colleague. Under the hood, it's still generating a likely continuation one piece at a time.

## Fluency is not accuracy

Because the model is optimised to produce plausible text, it can produce **plausible but false** text, known as hallucination. It might invent a citation, misremember a date, or confidently describe a feature that doesn't exist. Newer models and tools, such as web search and document grounding, reduce this but don't eliminate it.

A useful mental model: an assistant's output is a **first draft from a fast, knowledgeable, occasionally overconfident collaborator**. Treat it accordingly.

## Getting better results

Most disappointing answers come from vague requests. A few habits help:

1. **State the goal and audience.** "Explain compound interest to a 12-year-old" gets a very different answer from "explain compound interest".
2. **Provide context.** Paste the relevant document, data or background. The model can't read your mind or your files unless you give them to it.
3. **Specify constraints.** Length, format, tone, what to avoid.
4. **Show an example.** One sample of what good looks like is often more effective than a description.
5. **Iterate.** Treat it as a conversation. "Make it shorter", "more formal", "what are the weaknesses of this argument?"
6. **Ask it to reason or check.** Asking for steps, assumptions or a list of uncertainties can surface errors.

## Use judgment

- **Verify what matters.** Check facts, numbers, quotes and legal or medical information against reliable sources.
- **Protect sensitive data.** Know your organisation's policy before pasting confidential information.
- **Stay responsible.** You own the final decision and the final text. The model is a tool, not an authority.

Used well, these tools make you faster and broaden what you can attempt. The skill to build is knowing what to ask, and knowing what to check.`,
  },
  {
    slug: 'centaurs-and-cyborgs',
    title: 'Working Alongside AI: Centaurs and Cyborgs',
    summary: 'What research says about who benefits from AI at work, and two ways to collaborate with it.',
    topic: 'ai',
    source: 'Co-Intelligence',
    author: 'Ethan Mollick',
    takeaways: [
      'AI capability is a "jagged frontier": excellent at some tasks, surprisingly weak at similar-looking ones.',
      'Inside the frontier, AI can raise quality and speed, often helping less experienced workers most.',
      'Outside it, blindly trusting AI makes results worse, so knowing the boundary is a key skill.',
      'Centaurs divide tasks between human and AI; cyborgs weave AI through every step.',
    ],
    cards: [
      { type: 'idea', title: 'The jagged frontier', body: 'AI is brilliant at some tasks and oddly bad at others that look similar. The skill is learning where that boundary sits for your own work.' },
      { type: 'idea', title: 'Centaurs and cyborgs', body: 'Some people divide work cleanly between themselves and AI (centaurs); others weave it into every step (cyborgs). Both beat using it blindly or not at all.' },
      { type: 'tip', title: 'Always invite AI to the table', body: 'Try AI on a wide range of your tasks, even ones you doubt it can do. You only discover its strengths and blind spots in your work by experimenting.' },
    ],
    body: `Ethan Mollick, a professor at the Wharton School, studies how people actually use AI at work. His book *Co-Intelligence* and the research he co-authored offer a practical picture of what changes when AI joins your team.

## The jagged frontier

In a widely discussed 2023 study, consultants at Boston Consulting Group were given realistic tasks, some with access to GPT-4 and some without. For tasks within the AI's capabilities, consultants using AI completed more tasks, finished faster and produced higher-quality work. The biggest gains went to those who started out as below-average performers.

But for a task deliberately designed to fall *outside* the AI's abilities, where the model would give a convincing but wrong answer, consultants using AI did **worse** than those without it. They trusted the output.

The researchers described AI's abilities as a **jagged frontier**. Tasks that seem equally difficult to us can fall on opposite sides of it, and the boundary keeps moving as models improve.

## Two ways to collaborate

Watching how successful participants worked, the researchers saw two patterns:

**Centaurs** divide the work. Like the mythical half-human, half-horse, there's a clear line: the human does the parts they're best at (judgment, framing, final decisions), and hands specific subtasks to AI (first drafts, data summaries, alternative options).

**Cyborgs** integrate deeply. They work with AI continuously at a fine-grained level: starting a sentence and letting the model finish it, asking for critique of each paragraph, pushing back and refining in a tight loop.

Both approaches can work. The common thread is active engagement: neither group simply pasted in a task and accepted whatever came back.

## Mollick's principles

Mollick suggests a few rules of thumb:

1. **Always invite AI to the table.** Try it on many of your tasks. You learn the frontier for *your* work only by experimenting.
2. **Be the human in the loop.** Check, question and own the output, especially for facts and high-stakes decisions.
3. **Treat it like a person, but tell it what kind of person.** Giving the AI a role and context ("you are a sceptical reviewer") shapes its responses.
4. **Assume this is the worst AI you will ever use.** Capabilities are improving quickly, so revisit tasks it couldn't handle before.

## What this means for your skills

As AI handles more routine work, expertise still matters. Expertise is how you spot a confident wrong answer, frame a problem well and judge what "good" looks like. The workers who thrive will be those who combine domain knowledge with a practised sense of where the jagged frontier lies.`,
  },
  {
    slug: 'psychology-of-money',
    title: 'The Psychology of Money: Time, Compounding and Enough',
    summary: 'Why behaviour matters more than intelligence when it comes to building wealth.',
    topic: 'money',
    source: 'The Psychology of Money',
    author: 'Morgan Housel',
    takeaways: [
      'How you behave with money matters more than how much you know about finance.',
      'Compounding rewards time above all; staying invested matters more than perfect returns.',
      'Wealth is what you don\'t see: money not spent, giving you options and independence.',
      'Knowing what is "enough" protects you from risking what you have for what you don\'t need.',
    ],
    cards: [
      { type: 'idea', title: 'Compounding needs time', body: 'Most of Warren Buffett\'s wealth was earned after age 65, not because he got better, but because compounding had decades to work. Starting early matters more than starting big.' },
      { type: 'quote', title: 'On enough', body: 'The hardest financial skill is getting the goalpost to stop moving.' },
      { type: 'idea', title: 'Wealth is what you don\'t see', body: 'Rich is the car you see someone drive. Wealthy is the money they didn\'t spend on it. Wealth buys options, time and independence.' },
      { type: 'tip', title: 'Plan for surprises', body: 'Build a margin of safety (savings, lower debt, flexible plans) so that a bad surprise doesn\'t force you to sell or give up at the worst moment.' },
    ],
    body: `Morgan Housel's *The Psychology of Money* argues that financial success is less about intelligence than behaviour. A genius who panics, overspends or takes reckless risks can lose to an ordinary person who stays patient and humble.

## Behaviour beats knowledge

Housel tells the story of Ronald Read, a janitor and petrol station attendant who left an estate of about eight million dollars when he died in 2014. He had no special knowledge. He saved what he could, invested in blue-chip stocks and waited for decades. Meanwhile, plenty of highly paid, sophisticated people have gone bankrupt.

Finance is unusual in this way. Patience and temperament matter more than analytical brilliance.

## Time is the engine

Warren Buffett is a remarkable investor, but much of his wealth came simply from investing for a very long time. He started as a child, and the large majority of his net worth was accumulated after his mid-sixties. Compounding grows slowly, then dramatically.

The lesson for the rest of us isn't to chase the highest returns. It's to earn **good returns you can stick with for the longest time**. Avoiding the big mistakes, like selling in a panic or betting everything on one idea, matters more than finding the perfect investment.

## Wealth is what you don't see

We judge wealth by what's visible: cars, houses, clothes. But Housel distinguishes being **rich** (current income and spending) from being **wealthy** (assets you haven't spent). Wealth is the money not spent on the car, and it's invisible by definition.

What does wealth buy? Above all, **control over your time**: the ability to do what you want, when you want, with whom you want. Housel argues that is the highest dividend money pays.

## Enough

The hardest financial skill, Housel says, is getting the goalpost to stop moving. If expectations rise with every gain, you'll never feel satisfied, and you'll be tempted to risk what you have and need for what you don't have and don't need. Some people have been ruined this way despite already having more than enough.

Knowing your "enough" is protection, not a lack of ambition.

## Leave room for error

Plans rarely go to plan. Housel recommends a **margin of safety**: savings, moderate debt and flexible expectations. That way, recessions, job losses or medical bills don't force you into bad decisions at the worst time. Survival is what lets compounding work.

## Save for no reason

You don't need a specific goal to save. Savings are a buffer against surprises and a source of options you can't foresee yet. Keep your ego out of your spending, and your savings rate will take care of a lot.`,
  },
  {
    slug: 'pay-yourself-first',
    title: 'Pay Yourself First: Automating Good Money Habits',
    summary: 'An old principle that removes willpower from saving, plus a simple system to apply it.',
    topic: 'money',
    source: 'The Richest Man in Babylon',
    author: 'George S. Clason',
    takeaways: [
      'Set aside savings the moment income arrives, before any spending.',
      'Automating transfers removes willpower and decision fatigue from saving.',
      'Build an emergency fund first, then invest for the long term.',
      'Increase your savings rate gradually, especially when your income rises.',
    ],
    cards: [
      { type: 'idea', title: 'Pay yourself first', body: 'Save a fixed share of income the moment it arrives, before spending anything. Automating it removes willpower from the equation.' },
      { type: 'tip', title: 'The 30-day rule', body: 'For non-essential purchases, wait 30 days. If you still want it, buy it. Most impulse wants fade.' },
      { type: 'tip', title: 'Save your raises', body: 'When your income goes up, direct at least half the increase to savings before your lifestyle adjusts. You won\'t miss money you never got used to.' },
    ],
    body: `George S. Clason's *The Richest Man in Babylon* (1926) tells personal finance lessons through parables set in ancient Babylon. Its most famous lesson is simple: **a part of all you earn is yours to keep.** Today we call it *paying yourself first*.

## The principle

Most people save whatever is left at the end of the month, and there usually isn't much. Paying yourself first reverses the order. When income arrives, a set portion goes straight to savings, and you live on the rest. Clason suggested at least a tenth. Many modern guides recommend 10 to 20% where possible, but any consistent amount beats none.

Why does order matter? Spending expands to fill the money available. Parkinson's Law applies to budgets as well as time. If the savings are already gone from your current account, you adapt to what's left without much pain.

## Automate it

The modern superpower here is automation. Set up a standing transfer from your current account to savings or investments for the day after payday. Use workplace pension or retirement contributions if they're available, especially when an employer matches them, which is effectively free money.

Automation works because it:

- **Removes willpower.** You decide once rather than every month.
- **Uses inertia in your favour.** Defaults are powerful, and now the default is saving.
- **Avoids "mental accounting" traps.** Money you never see is less tempting to spend.

## A simple order of operations

Specific advice depends on where you live and your circumstances, but a common sequence is:

1. **Starter emergency fund.** A small buffer for unexpected costs, so surprises don't go onto credit cards.
2. **Pay down high-interest debt.** Interest on credit cards often outweighs typical investment returns.
3. **Full emergency fund.** Many guides suggest three to six months of essential expenses, kept accessible.
4. **Invest for the long term.** Tax-advantaged accounts first where available, using diversified, low-cost funds.

## Make it grow

- **Increase gradually.** Raise your savings rate by 1% every few months. It's barely noticeable.
- **Save your raises.** When income rises, send at least half the increase to savings before your lifestyle catches up.
- **Use friction against impulse buys.** The 30-day rule, unsubscribing from marketing emails and removing saved card details all add healthy friction.

## The bigger point

Clason's other lessons, such as controlling expenses, making money work for you and guarding against loss, all depend on this first step. It isn't about deprivation. It's about making sure future you is paid as reliably as your landlord, your phone company and your favourite shop.

*This lesson is general education, not personal financial advice.*`,
  },
  {
    slug: 'sleep-the-foundation',
    title: 'Sleep: The Foundation Everything Else Rests On',
    summary: 'What sleep does for your brain and body, and practical ways to get more of the good kind.',
    topic: 'health',
    source: 'Why We Sleep',
    author: 'Matthew Walker',
    takeaways: [
      'Most adults need roughly seven to nine hours; consistently getting less carries real costs.',
      'Sleep supports memory consolidation, emotional regulation, immune function and metabolic health.',
      'Consistency (the same wake time daily) is one of the most powerful levers for better sleep.',
      'Light, temperature, caffeine and alcohol all have big effects. Manage them deliberately.',
    ],
    cards: [
      { type: 'idea', title: 'Sleep is the foundation', body: 'Sleep consolidates memory, regulates mood and supports repair. Consistently getting under seven hours undermines nearly every other health habit.' },
      { type: 'tip', title: 'Anchor your wake time', body: 'Get up at the same time every day, weekends included. A steady wake time sets your body clock more reliably than an early bedtime.' },
      { type: 'tip', title: 'Morning light', body: 'Getting outdoor light within an hour of waking helps set your circadian rhythm, improving alertness by day and sleep at night.' },
      { type: 'tip', title: 'Mind the caffeine curfew', body: 'Caffeine lingers for hours. Many sleep experts suggest none after early afternoon if you struggle to fall or stay asleep.' },
    ],
    body: `Matthew Walker's *Why We Sleep* brought sleep science to a wide audience. Some of the book's specific claims have been debated by other researchers, but its central message is well supported: **sleep is not optional downtime. It is active, essential maintenance for the brain and body.**

## How much do we need?

Major health organisations recommend that most adults get **seven to nine hours** a night. Needs vary a little between individuals, but very few people do well on much less over the long term, even if they feel they've adapted. Sleep-deprived people are notoriously poor judges of their own impairment.

## What sleep does

Sleep moves through cycles of lighter sleep, deep slow-wave sleep and REM (dreaming) sleep, each lasting roughly 90 minutes.

- **Memory and learning.** Sleep helps consolidate what you learned during the day and prepares the brain to take in new information.
- **Emotional regulation.** After poor sleep, the brain's emotional centres become more reactive, which is why everything feels harder when you're tired.
- **Physical health.** Chronic short sleep is associated with higher risks of weight gain, impaired blood sugar control, cardiovascular problems and weaker immune responses.
- **Safety.** Drowsy driving causes a significant share of road accidents.

## The two drivers of sleep

Two processes govern when you feel sleepy:

1. **Sleep pressure.** A chemical called adenosine builds up the longer you're awake. Caffeine works by blocking adenosine receptors, masking the tiredness rather than removing it.
2. **The circadian rhythm.** An internal roughly 24-hour clock, set mainly by light, that times alertness and sleepiness.

Good sleep happens when both line up.

## Practical habits

- **Keep a consistent schedule.** The same wake time every day, including weekends, is one of the most effective changes you can make.
- **Get morning light, dim evenings.** Outdoor light early in the day strengthens your rhythm. Lower the lights and screen brightness in the evening.
- **Keep it cool and dark.** A cool bedroom, often suggested at around 18°C (65°F), helps your body temperature drop for sleep.
- **Watch caffeine.** Its effects can last many hours, so consider an early-afternoon cut-off.
- **Be careful with alcohol.** It may help you nod off, but it fragments sleep and suppresses REM.
- **Don't fight wakefulness in bed.** If you can't sleep after about 20 minutes, get up, do something calm in dim light, and return when sleepy.

If you consistently struggle with sleep, snore loudly or feel exhausted despite enough time in bed, talk to a doctor. Conditions like sleep apnoea and insomnia are common and treatable.

*This lesson is general information, not medical advice.*`,
  },
  {
    slug: 'zone-2-cardio',
    title: 'The Case for Easy Cardio: Zone 2 Training',
    summary: 'Why lots of gentle, conversational exercise builds the base for long-term health and fitness.',
    topic: 'health',
    source: 'Outlive',
    author: 'Peter Attia',
    takeaways: [
      'Zone 2 is steady exercise at a pace where you can still talk, but not sing.',
      'It builds aerobic fitness and metabolic health with relatively low strain and injury risk.',
      'A few hours a week, plus some harder efforts and strength training, makes a strong routine.',
      'Cardiorespiratory fitness is among the strongest predictors of healthy longevity.',
    ],
    cards: [
      { type: 'tip', title: 'Zone 2 cardio', body: 'Exercise at a pace where you can still hold a conversation. A few hours a week builds aerobic base and metabolic health with little injury risk.' },
      { type: 'tip', title: 'The talk test', body: 'In Zone 2 you can speak in full sentences but would not want to sing. If you can only manage a few words, you have drifted too hard.' },
      { type: 'idea', title: 'Fitness predicts longevity', body: 'Large studies consistently find that higher cardiorespiratory fitness is linked to substantially lower risk of death from all causes.' },
      { type: 'idea', title: 'Walking boosts creativity', body: 'People generate noticeably more creative ideas while walking than while sitting. Stuck on a problem? Take it for a walk.' },
    ],
    body: `Physician Peter Attia's *Outlive* focuses on extending healthspan, the years you live in good health. Exercise is central to his approach, and one form gets particular emphasis: steady, moderate **Zone 2** cardio.

## What is Zone 2?

Training "zones" divide exercise intensity into bands. Different systems use different numbers of zones, but Zone 2 generally means **steady effort at a comfortable, sustainable pace**. It's hard enough to raise your breathing but easy enough to keep going for a long time.

Simple ways to find it:

- **The talk test.** You can hold a conversation in full sentences, but you wouldn't want to sing.
- **Perceived effort.** It feels easy to moderate, perhaps a 3 or 4 out of 10.
- **Heart rate.** Many people land at roughly 60 to 70% of their maximum heart rate, though individual variation is large. Treat formulas as rough guides.

Brisk walking (especially uphill), easy cycling, swimming, rowing and gentle jogging can all be Zone 2, depending on your fitness.

## Why it matters

At this intensity, your body relies heavily on the aerobic system and on burning fat for fuel. Consistent Zone 2 training is thought to improve the number and efficiency of **mitochondria**, the cell's energy producers, and the body's ability to switch between fuel sources. This "metabolic flexibility" is linked to better blood sugar control.

More broadly, **cardiorespiratory fitness** is one of the strongest predictors of how long and how well people live. Large observational studies have found that people in the highest fitness groups have substantially lower all-cause mortality than those in the lowest, and that moving out of the very lowest group is associated with especially large benefits.

## Why easy is underrated

Many people exercise in a moderately hard "grey zone" every time: too hard to recover from easily, not hard enough to build top-end fitness. Endurance athletes often follow a pattern where most of their training, frequently around 80%, is easy, and a small portion is genuinely hard.

Zone 2 is also more sustainable. It's lower in injury risk, doesn't leave you wrecked, and can double as social time, thinking time or podcast time.

## Building a routine

Attia suggests that a meaningful dose for many people is around **three hours a week** of Zone 2, for example four 45-minute sessions. Pair that with:

- **Some higher-intensity work** (such as short intervals once a week) to build maximal aerobic capacity.
- **Strength training** two or three times a week to preserve muscle and bone as you age.
- **Stability and mobility work** to stay capable and injury-free.

If you're starting from little activity, any movement is a win. Begin with walks, build consistency, and progress gradually. Check with a doctor before starting if you have health conditions.

*This lesson is general information, not medical advice.*`,
  },
  {
    slug: 'tactical-empathy',
    title: 'Tactical Empathy: Lessons From a Hostage Negotiator',
    summary: 'How labelling, mirroring and calibrated questions make hard conversations easier.',
    topic: 'communication',
    source: 'Never Split the Difference',
    author: 'Chris Voss',
    takeaways: [
      'People want to feel understood before they will consider your view.',
      'Labelling emotions ("It seems like...") lowers tension and builds trust.',
      'Mirroring a few key words invites people to keep talking and reveal more.',
      'Open "how" and "what" questions turn opponents into problem-solving partners.',
    ],
    cards: [
      { type: 'tip', title: 'Tactical empathy', body: 'Label the other side\'s feelings ("It seems like you\'re worried about timing"). Feeling understood lowers defences and opens negotiation.' },
      { type: 'tip', title: 'Mirroring', body: 'Repeat the last few words someone said, as a gentle question. It signals you are listening and prompts them to elaborate, often revealing what really matters.' },
      { type: 'tip', title: 'Ask calibrated questions', body: '"How am I supposed to do that?" or "What\'s the biggest challenge you face here?" invites the other side to help solve your problem instead of defending their position.' },
    ],
    body: `Chris Voss spent years as the FBI's lead international kidnapping negotiator. In *Never Split the Difference*, he argues that the techniques that work in life-or-death negotiations also work in salary talks, sales calls and family disagreements, because they're built on how people actually respond under pressure.

## Emotions first, logic second

Classic negotiation advice treats people as rational actors trading offers. Voss's experience was different. People are driven by emotion, and they won't consider your perspective until they feel theirs has been understood.

His answer is **tactical empathy**: deliberately understanding and acknowledging the other side's feelings and viewpoint. It doesn't mean agreeing with them. It means showing you see where they're coming from, and using that to make progress.

## Labelling

A **label** names the emotion or dynamic you observe, usually starting with:

- "It seems like..."
- "It sounds like..."
- "It looks like..."

For example: "It sounds like you're frustrated that this has taken so long." Then **stay quiet** and let the label land.

Labelling negative emotions tends to defuse them, a finding that echoes psychology research on putting feelings into words. Labelling positive ones reinforces them. Voss also recommends an **accusation audit**: listing the worst things the other person might think about you and saying them first ("You probably think I'm being unreasonable..."). It takes the sting out.

## Mirroring

A **mirror** is simply repeating the last one to three critical words someone said, with a slight upward inflection:

> "We need this done by Friday."
> "By Friday?"
> "Yes, because the client presentation got moved up..."

It feels almost too simple, but it encourages people to elaborate, builds rapport, and often surfaces information you'd never have asked about.

## Calibrated questions

Instead of closed questions (which invite "no") or demands, Voss favours open questions that start with **"how"** or **"what"**:

- "How am I supposed to do that?"
- "What's the biggest challenge you face with this?"
- "What would need to be true for this to work for you?"

These questions give the other side a feeling of control while inviting them to work on *your* problem. "How am I supposed to do that?" is a polite way of saying no that keeps the conversation going.

## Aim for "that's right"

Voss argues that the most powerful moment in a negotiation is when the other person says **"that's right"**. It means they feel truly understood, usually after you summarise their position and feelings accurately. That's when real movement becomes possible.

These skills take practice. Try one at a time in low-stakes conversations, such as a label with a colleague or a mirror with a friend, and notice how people respond.`,
  },
  {
    slug: 'pyramid-principle',
    title: 'The Pyramid Principle: Lead With the Answer',
    summary: 'A structure for emails, reports and presentations that busy people can follow at a glance.',
    topic: 'communication',
    source: 'The Pyramid Principle',
    author: 'Barbara Minto',
    takeaways: [
      'Start with your main point or recommendation, then give the supporting arguments.',
      'Group supporting ideas into a small number of logical, non-overlapping categories.',
      'Use Situation, Complication, Question to set up why your answer matters.',
      'Readers who stop after two sentences should still get the message.',
    ],
    cards: [
      { type: 'idea', title: 'Lead with the bottom line', body: 'State your conclusion first, then the supporting points. Busy readers decide in the first two sentences whether to keep reading.' },
      { type: 'tip', title: 'Group in threes', body: 'Organise supporting points into a few clear, non-overlapping groups, often three. More than five and readers lose the thread.' },
      { type: 'tip', title: 'Situation, complication, question', body: 'Set up your message with what the reader already knows, what changed, and the question that raises. Then give your answer.' },
    ],
    body: `Barbara Minto developed the Pyramid Principle at McKinsey in the 1960s and 70s to help consultants write more clearly. Decades later it's still taught widely, because the problem it solves hasn't gone away. Most business writing makes readers work too hard to find the point.

## The core idea

Many of us write in the order we *thought*: background first, then analysis, then, finally, the conclusion. That's natural for the writer and exhausting for the reader, who has to hold everything in their head while wondering where it's going.

Minto's alternative is to **put the main point at the top**, then support it with a small set of grouped arguments, each of which can be supported by details beneath it. It looks like a pyramid:

- **Top:** the governing thought, your answer or recommendation.
- **Middle:** key arguments supporting it, usually two to five.
- **Base:** data, examples and evidence for each argument.

A reader can stop at any level and still have the most important information.

## Rules for the pyramid

1. **Ideas at any level summarise the ideas below them.** Each supporting point should answer the question raised by the point above it, usually *why?* or *how?*
2. **Ideas in a group are the same kind of idea.** Don't mix reasons with steps or problems with solutions.
3. **Ideas in a group are logically ordered:** by time (first, second, third), by structure (by region, by department), or by importance (most to least).

Minto also uses the principle of **MECE**: groups should be *mutually exclusive* (no overlaps) and *collectively exhaustive* (no gaps).

## Setting up the answer: SCQ

Leading with the answer doesn't mean skipping context. Minto suggests a short introduction using:

- **Situation:** something the reader already knows and agrees with. "We launched the new app in March."
- **Complication:** what changed or what's wrong. "Retention has dropped 20% since the redesign."
- **Question:** the question this raises, often unstated. "What should we do?"

Then deliver the **Answer**: "We should restore the old onboarding flow while we test fixes, for three reasons..."

## In everyday work

- **Emails.** Put the ask or conclusion in the first line, or even the subject: "Decision needed by Thursday: approve Q3 budget?"
- **Presentations.** The title of each slide should state its takeaway ("Churn is concentrated in new users") rather than a topic ("Churn analysis").
- **Updates.** "We're on track for launch; two risks need attention" beats a chronological diary of the week.

Clear structure is a form of respect. It tells your reader you've done the hard work of thinking so they don't have to.`,
  },
];
