# Puzzle Health Voice Guide (v1)

## Product Promise
One agent. One goal. Clear reasoning.

Users should always be able to answer:
1. What should I do today?
2. How close am I?
3. Why this goal?

---

## Core Tone
- Calm
- Direct
- Factual
- Respectful
- Never guilt-inducing

### We are
- precise
- concise
- honest

### We are not
- motivational coachy
- noisy
- preachy
- over-explanatory

---

## Writing Rules

1. **One screen, one job**
   - Home = action
   - Signals = trust
   - History = reflection

2. **Keep primary copy short**
   - Headlines: <= 7 words preferred
   - Explanations: 1 sentence
   - Avoid multi-paragraph UI copy

3. **Use operational language**
   - Say: "2,400 steps to go today"
   - Avoid: "You can do it! Keep pushing"

4. **Use human labels, not internal enums**
   - `weekday_only` -> "Weekday-focused"
   - `weekend_warrior` -> "Weekend-heavy"

5. **No precision theater**
   - Round targets to sensible values (50/100)
   - Avoid awkward exact values unless clinically necessary

6. **No guilt framing**
   - Say: "off target"
   - Avoid: "failed", "missed badly", "you should"

7. **No hype claims**
   - Avoid "best", "perfect", "magic" in product-facing copy

---

## Canonical UI Copy Patterns

## Home (Command Center)
- Section label: `Today`
- Primary: `{todaySteps} / {targetSteps} steps`
- Substate complete: `Today complete.`
- Substate incomplete: `{remaining} steps to go today.`
- Weekly line: `Goal: {target} steps daily this week`
- Reason line: one sentence max
- Weekly status: `{daysOnTarget}/7 days on target`
- Feedback prompt: `Was this goal right for you this week?`

## Signals (Trust Center)
- Title: `Signals`
- Subtitle: `How your goal is chosen`
- Cards:
  - `Baseline (30 days)`
  - `Pattern`
  - `4-week adherence`
- Trend summary: `This week: {x}% on target`

## History (Reflection)
- Subtitle: `Previous goals and outcomes`
- Row title: `{target} steps daily goal`
- Row metric: `{x}% on target`

## Onboarding
- Permission explanation: `To set your first goal, we need your recent health data.`
- Privacy line: `Read-only. Stored on your device.`

---

## Forbidden Phrases
- "You got this!"
- "No excuses"
- "Crushing it"
- "Don’t be lazy"
- "Perfect plan"
- "Guaranteed results"

---

## Example Rewrites
- "Today counts if you reach 3,800 steps" -> "3,800 steps to go today."
- "Past focuses and outcomes" -> "Previous goals and outcomes"
- "Data" -> "Signals"

---

## Decision Checklist Before Shipping New Copy
- Is this sentence necessary?
- Is it actionable or trust-building?
- Could it be shorter?
- Does it avoid guilt/hype?
- Would this still read well if repeated daily for 6 months?

If any answer is no, rewrite.
