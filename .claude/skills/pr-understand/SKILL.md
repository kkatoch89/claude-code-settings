---
name: pr-understand
description: Reads a pull request end-to-end so the model is primed to act on follow-up instructions about it. Builds a solid grasp of what the PR is trying to achieve and how it achieves it, then signals readiness and waits for further direction. Use when the user wants the model to familiarize itself with a PR (by URL or number) before doing anything else with it, or says things like "get up to speed on this PR" or "read this PR first".
---

Familiarize yourself with the pull request the user provides, then stop and wait for further instructions. Do not start reviewing, summarizing at length, or modifying anything yet — the user will tell you what to do next once you confirm you understand it.

## Inputs

The user provides a PR URL or number. If they haven't, ask for one before proceeding.

## What to do

1. Read the PR metadata and description with `gh pr view <pr>` (include body, labels, linked issues, and any linked tickets).
2. Read the full diff with `gh pr diff <pr>`.
3. Read any CLAUDE.md files in the directories the PR touches so your understanding reflects the repo's conventions.
4. If the diff references unfamiliar functions, types, or call sites, read enough surrounding code to genuinely understand them — don't guess.

Do this work quietly. One short "Reading the PR..." line is enough narration while you work.

## When you're done

Reply with a short confirmation that has two parts, in plain prose (no headers, no heavy bullet lists):

1. **What the PR is trying to achieve** — the goal, in one or two sentences.
2. **How it achieves it** — the main mechanism or approach, in one or two sentences. Mention the key files only if it helps.

Then end with a single line letting the user know you're ready for further instructions, e.g. "Ready for next steps."

Do not propose changes, run a review, or take any other action until the user gives you the next instruction.
