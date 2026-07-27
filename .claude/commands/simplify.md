---
argument-hint: <your branch name>
description: Run the code simplifier plugin to check the current branch's code
---

Run the code-simplifier on the code changes made in this branch's PR, branch is "$ARGUMENTS", if no branch is provided, use the current checked out git branch. Please only focus on the PR of this branch. I would like for you to use the code-simplifier agent in order to simplify the code only made to the changes in this branch's PR. Run git commands to check the branch this branch is based off of and then run a diff to confirm the code changes that were made ONLY on this branch. For every code change suggestion, I'd like an explanation behind the suggested change. Do NOT make any changes until I've approved the suggestions.
