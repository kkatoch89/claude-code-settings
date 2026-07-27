---
argument-hint: <BE | exploration>
description: Create a technical plan document with changelog tracking and decision documentation
---

You are a technical document writer. Your task is to create a plan document for the current task.

Before writing, research the codebase and gather full context about the feature or task being planned. The document should reflect a thorough understanding of the existing architecture, patterns, and constraints.

## File Naming & Location

Determine the file path automatically:

1. **File name:** `[branch-name]_[MM-DD]_PLAN.md` where `[branch-name]` is the current git branch and `[MM-DD]` is today's month-day (e.g., `feature-IINT-112-assistant-pubsub_02-27_PLAN.md`)
2. **Location:** Determine which repo(s) the plan covers:
   - If it covers a **single repo** (e.g., chunky-kong): save to `/Users/karankatoch/instinct/docs/[repo-name]/` (e.g., `/Users/karankatoch/instinct/docs/chunky-kong/`)
   - If it covers **multiple repos** (e.g., chunky-kong + kong-fu): save to `/Users/karankatoch/instinct/docs/`
3. Run `git branch --show-current` in the relevant repo to get the branch name. Replace `/` with `-` in the branch name for the filename.

## Document Structure

### 1. Title
Clear, descriptive title for the plan.

### 2. Strict Rule (immediately after title)
Add this block verbatim:

> ## Strict Rule
> Every change to this document — whether a code update, architectural revision, or clarification — **MUST** be accompanied by an entry in the **[Changelog Tracker](#changelog-tracker)** at the bottom. No exceptions. Include the date, a summary of the change, and the author.

### 3. Metadata
Include: date, author, scope, relevant branches, related/parent documents.

### 4. Context & Motivation
The problem being solved, what prompted it, and the intended outcome.

### 5. Design Decisions
For each significant design decision, document ALL options that were considered using this format:

**Decision: [Title]**

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| A | ... | ... | ... |
| B | ... | ... | ... |

**Chosen:** Option X — [rationale]

Do NOT omit rejected alternatives. The goal is for a reader to understand *why* the chosen approach was selected without needing to ask. If a decision was obvious and had no real alternatives, a brief explanation is sufficient — no need for a full table.

### 6. Implementation Plan
Step-by-step, grouped logically (e.g., backend then frontend). Include:
- Specific file paths to create/modify
- Code snippets where they clarify the approach
- Order of operations and dependencies between steps

### 7. Verification
How to test the changes end-to-end — commands to run, manual test steps, what to check.

### 8. Risks & Mitigations
If applicable — what could go wrong and how to handle it.

### 9. Changelog Tracker (at the very bottom)
Always end the document with:

```markdown
---

## Changelog Tracker

| Date | Author | Change | Notes |
|------|--------|--------|-------|
| YYYY-MM-DD | Author | Created document | Initial version |
```

## Argument-Specific Instructions

**If argument is "exploration":**

Override the file naming and location rules above:
1. **File name:** `[feature-name]_[MM-DD].md` where `[feature-name]` is a short, descriptive snake_case name for the feature being explored (e.g., `assistant_02-28.md`, `patient_search_02-28.md`). Do NOT include a branch name or `_PLAN` suffix.
2. **Location:** Always save to `/Users/karankatoch/instinct/docs/kong-fu/`
3. The document structure remains the same, but frame the content as an exploration/research document rather than a strict implementation plan.

**If argument is "BE":**

Additionally, include Mermaid diagrams where applicable to illustrate:
- Sequence diagrams for request lifecycles and data flow
- State machine diagrams for state transitions
- Entity relationship diagrams for data model changes
- Flowcharts for decision logic or event handling

Use ```mermaid code blocks. Prefer diagrams over prose when explaining flows, state transitions, or system interactions. Every non-trivial flow or state machine should have a corresponding diagram.

**If no argument is provided:**

Skip Mermaid diagrams unless they are essential to understanding the plan. Focus on clear prose and code snippets instead.

---

Now create the plan document based on the current task context. Use "$ARGUMENTS" to determine whether to include Mermaid diagrams.
