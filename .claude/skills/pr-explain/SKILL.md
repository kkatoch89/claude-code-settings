---
name: pr-explain
description: Walks through a pull request one topic at a time, fully explaining each change before moving on, and only advancing once the user confirms understanding. Builds a deep picture of the PR by reading its description, diff, and a full code review (run regardless of draft status), then breaks the explanation into ordered topics. Use when the user wants to learn what's happening in a PR, asks to "explain a PR", or wants tutoring-style answers about a pull request's changes.
---

Explain a pull request to the user one topic at a time, only advancing when they're satisfied with the current topic.

## Inputs

The user provides a PR URL or number. If they haven't, ask for one before proceeding.

## Phase 1 — Build understanding

Gather everything you need before explaining anything. Do this work quietly; one short "Reading the PR..." line is enough narration.

1. Read the PR metadata and description with `gh pr view <pr>` (include body, labels, linked issues).
2. Read the full diff with `gh pr diff <pr>`.
3. Run the `code-review` skill against the PR for an independent technical pass. **Override its eligibility check**: `code-review` normally skips draft PRs, closed/merged PRs, and PRs it has already reviewed — for this skill you must run the review regardless of PR state or prior reviews. Do not post the review back to GitHub; only use it to inform your explanation.
4. Read any CLAUDE.md files in directories the PR touches so your explanations reflect the repo's conventions.
5. If the diff references unfamiliar functions, types, or call sites, read enough surrounding code to explain them accurately — don't guess.

## Phase 2 — Plan the topics

Once you understand the PR, decide on an ordered list of topics that cover it end-to-end. Topics should follow the natural reading order of the change: motivation and context first, then the central change, then supporting changes, then risks or edge cases surfaced by the code review.

Show the user the topic list before starting (numbered, one short line each) and ask if they want to reorder, add, or drop anything. Don't move on until they sign off.

## Phase 3 — Walk through one topic at a time

For each topic, in order:

1. State which topic you're on (e.g. "Topic 2 of 6: ...").
2. Give a clear, conversational explanation in plain prose. No tables or heavy bullet lists unless the content truly demands it. Cite specific files and line numbers (`path/to/file.ts:42`) when pointing at code.
3. End by asking whether the explanation makes sense, or whether they want you to go deeper, rephrase, or come at it from a different angle.

Do not move on to the next topic until the user explicitly confirms they're satisfied. Follow-up questions, requests for examples, or "explain it differently" all stay on the current topic — keep iterating until they're happy.

When they confirm, move to the next topic and repeat. After the final topic is confirmed, say so plainly and stop.

## Style

Match the tone of the `explain` skill: conversational prose, no jargon walls, no decorative formatting. Lead with the "why" before the "what" whenever you can.
