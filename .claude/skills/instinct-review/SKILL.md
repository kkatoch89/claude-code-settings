---
name: instinct-review
description: Review changes for correctness, maintainability, rollout risk, and observability gaps.
---

# Instinct Review

Use this skill for:
- pull requests
- implementation plans
- risky refactors
- architecture changes

## Goal

Produce concise, high-signal engineering feedback.

## Working method

1. Understand what changed.
2. Check correctness.
3. Check edge cases.
4. Check rollout and migration risk.
5. Check observability and operational gaps.
6. Return findings grouped by severity.

## Output format

### Summary
- what was reviewed

### Findings
- grouped by severity
- short and actionable

### Rollout / Ops Notes
- migrations
- feature flags
- telemetry
- rollback

### Final Verdict
- approve
- approve with follow-ups
- needs changes

## Review methodology

Apply these review philosophies based on the code being reviewed. Reference files provide detailed guidance for each approach.

### Design and architecture reviews
Use the Kent Beck philosophy -- prioritize simplicity, TDD, incremental progress, and YAGNI. Ask whether the code does the simplest thing that could work, whether tests drive the design, and whether abstractions are earned rather than speculative.
- See [references/kent-beck-philosophy.md](references/kent-beck-philosophy.md)

### React and frontend reviews
Use the Kent C. Dodds philosophy -- AHA programming (Avoid Hasty Abstractions), test user behavior not implementation details, colocate related code, and prefer composition over configuration.
- See [references/kent-c-dodds-philosophy.md](references/kent-c-dodds-philosophy.md)

### Test quality audits
Evaluate whether each test provides genuine value. Flag duplicate coverage, over-mocking, implementation testing, tautological tests, and trivial tests. Every test should either prevent a regression or document critical behavior.
- See [references/test-quality.md](references/test-quality.md)

### Multi-perspective reviews
For complex PRs, run multiple review perspectives in parallel (design review, test quality review, stack-specific review), then synthesize findings using graph-of-thoughts to produce a unified report with confidence levels.

## Receiving feedback

When receiving review feedback on code you wrote or are responsible for:

1. **Verify first** -- check that the suggestion is technically correct for this codebase before implementing
2. **Ask if unclear** -- do not implement partially understood feedback; clarify all items first
3. **Push back with reasoning** -- if a suggestion breaks existing functionality, violates YAGNI, or is technically incorrect, say so with evidence
4. **Implement methodically** -- one item at a time, test each fix, verify no regressions
5. **Handle conflicts** -- when reviewers disagree, present both positions and let the team decide

For the full reference on evaluating and responding to feedback, see [references/receiving-feedback.md](references/receiving-feedback.md).

## Supporting files
- references/review-checklist.md
- references/kent-beck-philosophy.md
- references/kent-c-dodds-philosophy.md
- references/test-quality.md
- references/receiving-feedback.md
- scripts/changed-files.sh
- commands/quick.md
- commands/full.md

## Constraints
- do not invent facts
- do not pad the answer
- prioritize material issues over minor style nits
