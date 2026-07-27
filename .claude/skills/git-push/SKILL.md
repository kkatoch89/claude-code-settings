---
name: git-push
description: Review uncommitted/unpushed changes with instinct-engineering:instinct-review, then commit and push them. Use when the user wants to ship local work to the remote branch.
---

# Git Push

Review pending changes, then commit and push them.

## When to use

- User invokes `/git-push`
- User says "commit and push", "push my changes", "ship this", or similar
- Any time local changes need to make it to the remote with a review gate first

## Scope of "changes" reviewed

Everything that is not yet on the remote tracking branch:

1. **Unstaged** modifications (`git diff`)
2. **Staged** modifications (`git diff --cached`)
3. **Untracked** files (`git ls-files --others --exclude-standard`)
4. **Local commits** not yet pushed (`git log @{u}..HEAD`, if upstream exists)

If none of the above exist, stop and tell the user there is nothing to push.

## Workflow

### Step 1 — Detect repo and pending work

```bash
git rev-parse --show-toplevel        # confirm we're in a repo
git status --short                   # uncommitted changes
git branch --show-current            # current branch
git rev-parse --abbrev-ref @{u} 2>/dev/null  # upstream (may not exist)
git log --oneline @{u}..HEAD 2>/dev/null     # unpushed commits
```

If the working directory is clean AND there are no unpushed commits, exit early.

### Step 2 — Gather diffs to review

Build the full review surface:

- `git diff` (unstaged)
- `git diff --cached` (staged)
- For each untracked file, show its contents (skip lock files, binaries, `.env*`, anything that looks like a secret — flag and ask before including)
- `git log @{u}..HEAD --stat` and `git diff @{u}..HEAD` for unpushed commits

Limit each diff segment if huge; summarize plus show the most material hunks.

### Step 3 — Run instinct-review on the pending changes

Invoke the `instinct-engineering:instinct-review` skill on the gathered diff. The review must cover ONLY the uncommitted + unpushed work — not the whole branch history, not master.

Pass the review the context it needs:
- Branch name
- List of changed files (and untracked files)
- Diff content
- Any local commit messages already on the branch but unpushed

### Step 4 — Present findings, gate on user

Show the review output verbatim (Summary / Findings / Rollout Notes / Final Verdict).

Then ask the user how to proceed:

- **Proceed** → continue to commit + push
- **Fix first** → stop; let the user (or you, if asked) address findings before re-running
- **Proceed anyway** → user explicitly acknowledges remaining issues

Do NOT auto-proceed if the review verdict is "needs changes". Require explicit user approval.

### Step 5 — Stage uncommitted changes

If there are uncommitted changes:

- Stage specific files by name (avoid `git add -A` / `git add .` — they sweep in `.env`, secrets, build artifacts)
- Skip / refuse files that look like secrets (`.env*`, `*.pem`, `id_rsa`, `credentials.json`, etc.) and warn the user
- Confirm with the user before staging any file you're unsure about

### Step 6 — Commit

If there are staged changes after Step 5, create a NEW commit (never `--amend` unless the user asked). Use the `writing-git-commits` skill conventions: imperative subject, ~50 chars, body explaining what/why if non-trivial.

Use a HEREDOC and include the standard co-author trailer:

```bash
git commit -m "$(cat <<'EOF'
Subject in imperative mood

Optional body explaining what changed and why.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

Never use `--no-verify`. If a pre-commit hook fails, fix the underlying issue and create a NEW commit (not `--amend`).

### Step 7 — Pre-push validation (lint + typecheck)

Run the project's lint/format/typecheck gates against the working tree before pushing. These should mirror what CI will run, so a failure here means CI will fail.

For Node/yarn projects, detect which of these scripts exist in `package.json` and run the ones that do (skip silently if a script is absent):

1. **Typecheck** — try in order: `yarn types:check` → `yarn typecheck` → fall back to `yarn tsc --noEmit` if `tsconfig.json` exists
2. **Lint** — try in order: `yarn lint` → `yarn eslint src` (only if `src/` exists)
3. **Format check** — try in order: `yarn format:check` → `yarn prettier --check .`

For Elixir/mix projects (presence of `mix.exs`), run via direct `mix` — **do not** wrap in `ws run <service> ...`, even if `CLAUDE.md` suggests it for general development. The wrapper adds container startup overhead that's wasteful for a pre-push gate:

1. **Lint** — `mix lint` (covers compile --warnings-as-errors + format + credo in one shot for chunky-kong)
2. **Tests** — `mix test <path/to/changed_test_file ...>` for the test files touched by this push. Only fall back to a full `mix test` if the change has cross-cutting implications.

For other ecosystems (cargo, go, etc.), use the project's equivalent if obvious from `CLAUDE.md` or visible config; otherwise skip this step and note that you didn't find a known validation entrypoint.

If any check fails:
- **STOP**. Do not push.
- Report which check failed and the relevant output (truncate to the actionable bit).
- Ask the user whether to fix the issues now, push anyway (explicit override only), or abort.
- If the user opts to fix, address the failures and re-run the failed checks before proceeding.

Do not bypass with `--no-verify`-style escapes. If validation tooling itself is broken (not the code), surface that and ask.

### Step 8 — Push

```bash
git push                              # if upstream is set
git push -u origin <branch-name>      # if no upstream yet
```

**Never** force push (`--force`, `--force-with-lease`) unless the user explicitly asks. **Never** push to `main` / `master` unless that is clearly the current branch and the user explicitly wants it — warn first.

If the push is rejected (non-fast-forward), STOP. Do not auto-resolve with force or rebase. Report the rejection and ask the user how they want to handle it.

### Step 9 — Confirm

Report back:
- Commit SHA(s) pushed
- Branch and remote
- Any review findings the user opted to defer (so they aren't forgotten)

## Guardrails

- Always run the review BEFORE committing — never commit first and review later
- Never bypass hooks (`--no-verify`, `--no-gpg-sign`)
- Never force-push without explicit user instruction
- Never stage files that look like secrets without explicit confirmation
- Never amend an already-pushed commit
- If the branch is `main` / `master`, double-check with the user before pushing

## Edge cases

- **Detached HEAD**: refuse to push; tell the user to check out a branch first
- **No upstream**: ask which remote/branch to push to (default suggestion: `origin <current-branch>` with `-u`)
- **Diverged from remote**: stop and surface the divergence; do not auto-rebase or force-push
- **Multiple unrelated changes**: ask whether to split into multiple commits or bundle as one

## Composes with

- `instinct-engineering:instinct-review` — the review gate
- `writing-git-commits` — commit message conventions
- `pr-create` — natural follow-up once changes are pushed (do not invoke automatically)
