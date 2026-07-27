# Branch Workflow

Branch management conventions and workflow patterns for feature development.

## Branch Naming Conventions

### Feature Branches

Use a consistent prefix pattern that ties branches to tracking systems:

```
feature/<ticket-id>           # e.g., feature/PROJ-538
feature/<ticket-id>-<slug>    # e.g., feature/PROJ-538-add-auth
```

Acceptable prefixes by purpose:

| Prefix | Purpose |
|--------|---------|
| `feature/` | New features and enhancements |
| `fix/` | Bug fixes |
| `hotfix/` | Urgent production fixes |
| `refactor/` | Code restructuring |
| `chore/` | Maintenance tasks (deps, CI, tooling) |

### Rules

- Always branch off the primary branch (main or master)
- Use lowercase with hyphens for slugs
- Include ticket ID when a tracking system is in use
- Keep branch names concise but descriptive

## Primary Branch Detection

Repositories use either `main` or `master` as the primary branch. Detect it automatically:

```bash
# Determine primary branch from remote HEAD
primary_branch=$(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')
```

Never hard-code `main` or `master`. Always detect dynamically.

## Creating and Updating Feature Branches

Always check if the feature branch already exists before creating it:

```bash
# Update all references
git fetch origin

# Determine primary branch
primary_branch=$(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')

# Check if feature branch exists locally or remotely
git branch -a | grep "feature/<ticket>"

# If branch exists locally:
git checkout feature/<ticket>
git fetch origin
git rebase origin/$primary_branch  # Catch up to primary branch

# If branch exists only remotely:
git checkout -b feature/<ticket> origin/feature/<ticket>
git rebase origin/$primary_branch  # Catch up to primary branch

# If branch doesn't exist anywhere:
git checkout $primary_branch
git pull origin $primary_branch
git checkout -b feature/<ticket>
```

## Rebase Workflow

Prefer rebase over merge for keeping feature branches up to date. This keeps history linear and clean.

### Staying Current

```bash
git fetch origin
git rebase origin/$primary_branch
```

### Conflict Resolution

If conflicts occur during rebase:

1. **Stop and assess** -- do not attempt automatic resolution blindly
2. Review the conflicting files with `git status`
3. Resolve conflicts manually in each file
4. Stage resolved files: `git add <file>`
5. Continue the rebase: `git rebase --continue`
6. If the situation is complex, abort and discuss: `git rebase --abort`

### When to Rebase vs. Merge

| Situation | Strategy |
|-----------|----------|
| Updating feature branch from primary | Rebase |
| Integrating feature into primary | Merge (via PR) |
| Shared branch with other developers | Merge (avoid rewriting shared history) |
| Local-only branch cleanup | Rebase / interactive rebase |

## Commit Organization

### Before Creating a PR

Review your commit history and clean up if needed:

- Squash fixup commits
- Ensure each commit is a logical, self-contained change
- Verify commit messages follow the Tim Pope format (see `tim-pope-format.md`)

### Atomic Commits

Each commit should:
- Represent one logical change
- Leave the codebase in a working state
- Have a clear, descriptive message
- Be independently reviewable

## Push and PR Workflow

```bash
# Push feature branch to remote
git push -u origin feature/<ticket>

# Create PR (if using GitHub CLI)
gh pr create --title "Description" --body "Details"
```

### PR Checklist

Before opening a PR:
- [ ] Branch is rebased on latest primary branch
- [ ] All commits have clean messages
- [ ] Tests pass locally
- [ ] No unrelated changes included
- [ ] PR description explains what and why

## Branch Cleanup

After a PR is merged:

```bash
# Switch to primary branch and pull
git checkout $primary_branch
git pull origin $primary_branch

# Delete local feature branch
git branch -d feature/<ticket>

# Delete remote feature branch (if not auto-deleted)
git push origin --delete feature/<ticket>
```

## Quick Reference

```bash
# Start new feature
git fetch origin
primary=$(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')
git checkout $primary && git pull origin $primary
git checkout -b feature/<ticket>

# Stay current
git fetch origin && git rebase origin/$primary

# Push for review
git push -u origin feature/<ticket>

# Clean up after merge
git checkout $primary && git pull origin $primary
git branch -d feature/<ticket>
```
