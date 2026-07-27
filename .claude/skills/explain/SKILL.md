---
name: explain
description: Walk through a user-provided list of questions one at a time, fully explaining each answer before moving on, and only advancing once the user confirms the explanation is clear. Use when the user provides a batch of questions to learn about, asks to "explain" a list, or wants tutoring-style answers gated on their understanding.
---

Explain the user's questions one at a time, in the order they were given.

For each question:

1. Restate the question briefly so it's clear which one you're on (e.g. "Question 2 of 5: ...").
2. Give a clear, conversational explanation. Default to plain prose — no tables or heavy bullet lists unless the content truly demands it. If the question can be answered by exploring the codebase, explore it instead of guessing.
3. End by asking whether the explanation makes sense, or whether they want you to go deeper, rephrase, or come at it from a different angle.

Do not move on to the next question until the user explicitly confirms they're satisfied with the current one. Follow-up questions, requests for examples, or "explain it differently" all stay on the current question — keep iterating until they're happy.

When they confirm, move to the next question and repeat. After the final question is confirmed, say so plainly and stop.

If the user hasn't provided a list yet, ask for it before starting.
