---
name: pr-create
description: Create GitHub pull requests with automatic ticket ID formatting in the title and description. Optionally accepts tags (GitHub labels) that must already exist in the repo.
argument-hint: "[--tags tag1,tag2]"
---

# Create PR

Create GitHub pull requests with automatic ticket ID formatting in the description.

## When to use

Use this skill when creating pull requests to automatically format the PR description with the ticket ID heading.

Examples:
- User says: "Create a PR"
- User says: "Make a pull request"
- User invokes: `/pr-create`
- User invokes: `/pr-create --tags frontend,ui`

## Variables

RAW_ARGS: $ARGUMENTS
TAGS: parsed from RAW_ARGS after `--tags ` (comma-separated). Empty if not provided.

## Argument parsing

Skills receive arguments as a single string via `$ARGUMENTS`. There is no built-in
flag parser — treat flags as a naming convention that this skill parses itself.

- `--tags <csv>` — Optional. Comma-separated list of GitHub labels to attach to
  the PR. Each label must already exist in the target repo. Example:
  `--tags frontend,ui,accessibility`.

If a flag value contains spaces, expect it quoted (e.g. `--tags "needs review,ui"`).
Ignore unknown flags and warn the user rather than failing.

## What it does

1. Extracts the ticket ID from the current branch name (e.g., `feature/IINT-247` → `IINT-247`)
2. Parses `$ARGUMENTS` for optional `--tags` flag
3. **Validates every tag exists as a GitHub label in the repo — aborts if any is missing**
4. Prompts for PR title and description
5. Automatically adds `# [TICKET-ID]` at the top of the description
6. Creates the PR using `gh pr create` with:
   - Title in format: `[TICKET-ID] Description`
   - Description starting with ticket ID heading
   - `--label` set for each validated tag
   - Base branch: master (or user-specified)

## Tag validation

Tags map 1:1 to GitHub labels. Before creating the PR:

1. Fetch existing labels: `gh label list --limit 200 --json name --jq '.[].name'`
2. For each parsed tag, check whether it appears in the list (exact match, case-sensitive — GitHub labels are case-sensitive).
3. **If any tag is not found, STOP immediately.** Do not create the PR. Report:
   - Which tag(s) are missing
   - The closest existing labels (suggest up to 3 near-matches so the user can retry)
   - Instruct the user to either fix the spelling or create the label first (`gh label create <name>`)
4. Only proceed to `gh pr create` when every tag validates.

## Output format

**PR Title:**
```
[IINT-247] Short description of changes
```

**PR Description:**
```markdown
# [IINT-247]

[User's description goes here]

## Changes
- List of changes

## Testing
- How to test
```

Tags are attached as GitHub labels, not appended to the body.

## Workflow

```bash
# 1. Get current branch and extract ticket ID
git branch --show-current

# 2. Parse $ARGUMENTS for --tags. If present, split the comma-separated value
#    into a list; otherwise leave tags empty.

# 3. If TAGS is non-empty, validate against repo labels. STOP if any missing.
gh label list --limit 200 --json name --jq '.[].name'

# 4. Ask user for:
#    - PR title (without ticket prefix - we'll add it)
#    - PR description
#    - Base branch (default: master)

# 5. Create PR (one --label flag per validated tag)
gh pr create \
  --title "[TICKET-ID] Title" \
  --base master \
  --label "frontend" \
  --label "ui" \
  --body "$(cat <<'EOF'
# [TICKET-ID]

[User's description]
EOF
)"
```

## Examples

### Example 1: Simple PR
```
Branch: feature/IINT-247
Invocation: /pr-create
User title: Transform attachment to inline panel
User description: Adds inline expand/collapse for attachments

Result:
Title: [IINT-247] Transform attachment to inline panel
Body:
# [IINT-247]

Adds inline expand/collapse for attachments
```

### Example 2: PR with valid tags
```
Branch: feature/POE-123
Invocation: /pr-create --tags frontend,accessibility
Repo has labels: frontend, backend, accessibility, bug

Result:
- Validation passes for both tags
- PR created with title [POE-123] ... and labels: frontend, accessibility
```

### Example 3: PR with an invalid tag (aborts)
```
Branch: feature/POE-123
Invocation: /pr-create --tags frontend,front-end
Repo has labels: frontend, backend, accessibility

Result:
- Validation fails: `front-end` is not a label in this repo.
- Closest matches: frontend
- PR is NOT created. User is asked to either correct the spelling
  or run `gh label create front-end` before retrying.
```

## Error handling

- If no ticket ID found in branch name: Ask user to provide it
- If `gh` is not installed: Show error and installation instructions
- If not authenticated with GitHub: Prompt to run `gh auth login`
- If `--tags` is present but has no value: Warn and proceed without tags
- **If any passed tag is not a label in the repo: STOP. Do not create the PR. Report which tag(s) are missing and suggest near-matches.**

## Notes

- Always extracts ticket ID from branch name automatically
- Supports common branch formats: `feature/TICKET-123`, `TICKET-123-description`, `fix/TICKET-123`
- If ticket ID can't be extracted, asks user to provide it manually
- Base branch defaults to `master` but can be overridden
- Tags are optional; when provided they must map to existing repo labels
- Label matching is exact and case-sensitive (matches GitHub's own behavior)
