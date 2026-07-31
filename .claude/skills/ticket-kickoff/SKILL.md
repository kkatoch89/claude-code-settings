---
name: ticket-kickoff
description: Full ticket kickoff workflow — grill requirements, write PRD and implementation plan, post both to Jira, optionally create subtasks, and output workspace creation commands. Use when starting work on a new story or ticket.
---

# Ticket Kickoff

Orchestrates a full ticket kickoff: explore requirements → PRD → implementation plan → post to Jira → optionally create subtasks and workspaces.

Works in both a Coder workspace and on the laptop. The Jira commands and creds differ slightly between the two.

---

## Pre-flight

**1. Detect environment and load Jira credentials:**

```bash
if [ -d /opt/instinct ]; then
  # Coder workspace
  JIRA_CREDS="/opt/instinct/.emr/.jira-creds"
  JIRA_BASE=$(cat /opt/instinct/.emr/.jira-base 2>/dev/null || echo "https://instinctvet.atlassian.net")
  JIRA_EMAIL=$(node -e "console.log(JSON.parse(require('fs').readFileSync('$JIRA_CREDS','utf8')).email)")
  JIRA_TOKEN=$(node -e "console.log(JSON.parse(require('fs').readFileSync('$JIRA_CREDS','utf8')).token)")
else
  # Laptop
  JIRA_BASE="${JIRA_URL%/}"
  JIRA_EMAIL="$JIRA_USERNAME"
  JIRA_TOKEN="$JIRA_API_TOKEN"
fi
```

**2. Verify Jira auth:**

```bash
# Workspace:
jira whoami

# Laptop:
jira me
```

If this fails: tell the user to run `jira login` (workspace) or `jira init` (laptop) and stop.

**3. Identify the target ticket:**

- In workspace: run `jira linked`. If a ticket is already linked, use it. If none, ask the user for the key, then `jira link <KEY>`.
- On laptop: ask the user for the ticket key.

Fetch full details so you have context going into the interview:

```bash
# Workspace:
jira view <KEY>

# Laptop:
jira issue view <KEY>
```

---

## Phase 1 — Grill

Invoke the `grill-me` skill. The interview should reach a confident shared understanding of:

- What problem this ticket actually solves (user perspective AND technical perspective)
- Which repos are involved and how (roughly)
- Scope and complexity — is this a small contained change or a multi-repo effort?
- Constraints, dependencies, or unknowns that could change the plan

Don't advance to Phase 2 until you and the user have converged on the scope. If something is ambiguous and exploring the codebase would resolve it, explore it instead of guessing.

---

## Phase 2 — PRD

Invoke the `to-prd` skill. It synthesizes the conversation into a PRD and saves it to the `prd/` directory.

Note the file path it saves to — you'll need it in Phase 4.

---

## Phase 3 — Implementation Plan

Invoke the `prd-to-plan` skill. It breaks the PRD into tracer-bullet phases and saves the plan to the `plans/` directory.

Note the file path it saves to — you'll need it in Phase 4.

---

## Phase 4 — Post to Jira

Post both files as comments on the parent ticket. Write content to `/tmp` first to avoid shell quoting issues with multi-line strings.

**Post the PRD:**

```bash
{ echo "## Product Requirements Document"; echo; cat <prd-file>; } > /tmp/prd-comment.txt

# Workspace:
jira comment <KEY> "$(cat /tmp/prd-comment.txt)"

# Laptop:
jira issue comment add <KEY> --body "$(cat /tmp/prd-comment.txt)"
```

**Post the implementation plan:**

```bash
{ echo "## Implementation Plan"; echo; cat <plan-file>; } > /tmp/plan-comment.txt

# Workspace:
jira comment <KEY> "$(cat /tmp/plan-comment.txt)"

# Laptop:
jira issue comment add <KEY> --body "$(cat /tmp/plan-comment.txt)"
```

Confirm both comments posted before continuing.

---

## Phase 5 — Subtask Assessment

Based on the implementation plan, assess whether the work should be split into Jira subtasks. Present your recommendation with reasoning.

**Create subtasks when:**
- Work clearly spans multiple repos that can progress somewhat independently
- The plan has phases that map to distinct deliverables
- Parallel development by different people is realistic

**Don't create subtasks when:**
- Work is contained to one or two tightly coupled repos
- Phases must happen sequentially with tight context carry-over
- Scope is small or focused enough for one workspace

Show the user exactly which subtasks you'd create (title + which plan phases + which repos), then ask for confirmation. If they say no subtasks needed, stop here.

---

## Phase 6 — Create Subtasks (if approved)

Create each subtask via the Jira REST API (works in both environments without needing a separate CLI command).

**First, confirm the correct issue type name for this project:**

```bash
PROJECT_KEY=$(echo "<KEY>" | cut -d'-' -f1)
curl -s -u "$JIRA_EMAIL:$JIRA_TOKEN" \
  "$JIRA_BASE/rest/api/3/issue/createmeta?projectKeys=$PROJECT_KEY&expand=projects.issuetypes" \
  | node -e "
      const d = JSON.parse(require('fs').readFileSync('/dev/stdin','utf8'));
      (d.projects?.[0]?.issuetypes || []).forEach(t => console.log(t.name, t.subtask ? '(subtask)' : ''));
    "
```

Look for the type marked `(subtask)` — typically `"Subtask"`.

**Create each subtask:**

```bash
# Build payload with node to handle quoting safely
node -e "
  const payload = {
    fields: {
      project: { key: 'PROJECT_KEY' },
      issuetype: { name: 'Subtask' },
      parent: { key: 'PARENT_KEY' },
      summary: 'SUBTASK_TITLE',
      description: {
        version: 1, type: 'doc',
        content: [{ type: 'paragraph', content: [{ type: 'text', text: 'SUBTASK_DESCRIPTION' }] }]
      }
    }
  };
  process.stdout.write(JSON.stringify(payload));
" > /tmp/subtask.json

RESULT=$(curl -s -u "$JIRA_EMAIL:$JIRA_TOKEN" \
  -H "Content-Type: application/json" \
  -X POST "$JIRA_BASE/rest/api/3/issue" \
  -d @/tmp/subtask.json)

NEW_KEY=$(echo "$RESULT" | node -e "
  const d = JSON.parse(require('fs').readFileSync('/dev/stdin','utf8'));
  console.log(d.key || d.errorMessages?.[0] || JSON.stringify(d));
")
echo "Created: $NEW_KEY"
```

Repeat for each subtask. Collect all created keys.

In workspace only — link each new subtask to the current workspace so it appears in the Jira panel:

```bash
jira link <NEW_KEY>
```

---

## Phase 7 — Output Workspace Commands

Workspace creation must happen from the **host terminal** — the agent token inside a workspace cannot authenticate `coder create` as a user. Output the exact commands for the user to run locally.

Pass both the subtask key AND the parent key via `--jira-tickets` so the new workspace has the subtask for current work tracking AND the parent (whose comments hold the PRD + plan):

```
Subtasks created: <KEY-1>, <KEY-2>

Run these in your local terminal to spin up a workspace per subtask:

  emr create <key-1-lowercase> --jira-tickets <PARENT_KEY> <KEY-1>
  emr create <key-2-lowercase> --jira-tickets <PARENT_KEY> <KEY-2>

Each workspace will have the subtask pre-linked (for tracking) and the parent ticket pre-linked
(to view the PRD and implementation plan via `jira view <PARENT_KEY>`).
```

Done.
