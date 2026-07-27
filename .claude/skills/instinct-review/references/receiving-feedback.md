# Receiving Code Review Feedback

Reference for evaluating and responding to code review feedback. Emphasizes verification and reasoned pushback over blind agreement.

## Quick Start

Before implementing any review feedback:

1. **Verify** the suggestion is technically correct for this codebase
2. **Ask** clarifying questions if anything is unclear
3. **Push back** with reasoning if the suggestion is wrong
4. **Implement** and test one item at a time

## The Response Pattern

```
WHEN receiving code review feedback:

1. READ: Complete feedback without reacting
2. UNDERSTAND: Restate requirement in own words (or ask)
3. VERIFY: Check against codebase reality
4. EVALUATE: Technically sound for THIS codebase?
5. RESPOND: Technical acknowledgment or reasoned pushback
6. IMPLEMENT: One item at a time, test each
```

## Handling Unclear Feedback

```
IF any item is unclear:
  STOP - do not implement anything yet
  ASK for clarification on unclear items

WHY: Items may be related. Partial understanding = wrong implementation.
```

**Example:**
```
User: "Fix 1-6"
You understand 1,2,3,6. Unclear on 4,5.

WRONG: Implement 1,2,3,6 now, ask about 4,5 later
RIGHT: "I understand items 1,2,3,6. Need clarification on 4 and 5 before proceeding."
```

## Source-Specific Handling

### From the User
- **Trusted** - implement after understanding
- **Still ask** if scope unclear
- **Skip to action** or technical acknowledgment

### From External Reviewers
```
BEFORE implementing:
  1. Check: Technically correct for THIS codebase?
  2. Check: Breaks existing functionality?
  3. Check: Reason for current implementation?
  4. Check: Works on all platforms/versions?
  5. Check: Does reviewer understand full context?

IF suggestion seems wrong:
  Push back with technical reasoning

IF can't easily verify:
  Say so: "I can't verify this without [X]. Should I [investigate/ask/proceed]?"

IF conflicts with prior decisions:
  Stop and discuss first
```

**Guiding principle:** External feedback - be skeptical, but check carefully.

## YAGNI Check

```
IF reviewer suggests "implementing properly":
  grep codebase for actual usage

  IF unused: "This endpoint isn't called. Remove it (YAGNI)?"
  IF used: Then implement properly
```

If the feature isn't needed, don't add it -- regardless of who suggested it.

## Implementation Order

```
FOR multi-item feedback:
  1. Clarify anything unclear FIRST
  2. Then implement in this order:
     - Blocking issues (breaks, security)
     - Simple fixes (typos, imports)
     - Complex fixes (refactoring, logic)
  3. Test each fix individually
  4. Verify no regressions
```

## When to Push Back

Push back when:
- Suggestion breaks existing functionality
- Reviewer lacks full context
- Violates YAGNI (unused feature)
- Technically incorrect for this stack
- Legacy/compatibility reasons exist
- Conflicts with architectural decisions

**How to push back:**
- Use technical reasoning, not defensiveness
- Ask specific questions
- Reference working tests/code
- Involve the team if architectural

## Handling Conflicting Feedback

When multiple reviewers suggest contradictory approaches:

1. **Don't pick sides** - Present the conflict to the team
2. **Summarize both positions** - State each approach and its tradeoffs
3. **Ask for direction** - Let the team decide

**Example:**
```
Reviewer A suggests extracting to a helper function.
Reviewer B prefers keeping it inline for readability.

"Two conflicting suggestions: extract vs inline. Extraction adds reusability
but increases indirection. Inline keeps it readable but duplicates logic
if used elsewhere. Which approach do you prefer?"
```

Never implement one reviewer's suggestion while ignoring the other without discussing.

## Acknowledging Correct Feedback

When feedback IS correct:
```
"Fixed. [Brief description of what changed]"
"Good catch - [specific issue]. Fixed in [location]."
[Just fix it and show in the code]
```

Focus on what changed, not on excessive gratitude. The fix itself demonstrates understanding.

## Gracefully Correcting Pushback

If you pushed back and were wrong:
```
"You were right - I checked [X] and it does [Y]. Implementing now."
"Verified this and you're correct. My initial understanding was wrong because [reason]. Fixing."
```

State the correction factually and move on.

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Blind implementation | Verify against codebase first |
| Batch without testing | One at a time, test each |
| Assuming reviewer is right | Check if breaks things |
| Avoiding pushback | Technical correctness > comfort |
| Partial implementation | Clarify all items first |
| Can't verify, proceed anyway | State limitation, ask for direction |

## The Bottom Line

**External feedback = suggestions to evaluate, not orders to follow.**

Verify. Question. Then implement.
