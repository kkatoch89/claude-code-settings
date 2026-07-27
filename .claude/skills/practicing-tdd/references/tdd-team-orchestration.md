# TDD Team Orchestration Reference

Reference for orchestrating TDD across multiple agents. Defines team roles, communication protocol, and cycle management.

## Team Roles

| Name | Phase | File Scope | Hands Off To |
|------|-------|------------|--------------|
| `team-lead` | Orchestration | Any (read-only) | `tester` |
| `tester` | RED | `test/` only | `engineer` |
| `engineer` | GREEN | `lib/` only | `refactorer` |
| `refactorer` | REFACTOR + DOCUMENT | `lib/` only | `tester` |
| `documenter` (optional) | DOCUMENT | Any | -- |

One cycle: tester -> engineer -> refactorer -> tester (next task).
The `documenter` is a one-shot agent spawned post-completion, not part of the cycle.

## Spawning Agents

Always set `mode: "acceptEdits"` so agents can write files and run tests without blocking on user permission prompts.

Agent tool parameters for each member:

```
name: "tester"
subagent_type: "general-purpose"
mode: "acceptEdits"
team_name: "<your-team-name>"
```

```
name: "engineer"
subagent_type: "general-purpose"
mode: "acceptEdits"
team_name: "<your-team-name>"
```

```
name: "refactorer"
subagent_type: "general-purpose"
mode: "acceptEdits"
team_name: "<your-team-name>"
```

## Agent Prompt Requirements

Include this EXACT block in every agent prompt, after the identity section. Replace `<your-team-name>` with the actual team name.

```markdown
## Team Directory (use EXACT names in SendMessage)
- `team-lead` -- orchestrator, assigns tasks
- `tester` -- RED phase, writes failing tests
- `engineer` -- GREEN phase, makes tests pass
- `refactorer` -- REFACTOR phase, improves code quality

CRITICAL: Use these exact strings as the `recipient` in SendMessage.
Never use "orchestrator", "lead", "refacterer", or any variation.
```

Why: without this block agents infer names from context and guess wrong (`refacterer`, `orchestrator`, `@engineer`), causing misrouted messages and multi-hour stalls.

### Domain Skill References

Each agent prompt should include a "Before Starting" section that directs the agent to read the domain-appropriate skill for its role:

| Role | Skill to Read | Purpose |
|------|--------------|---------|
| `tester` | Testing skill for your stack | Test philosophy, assertions, patterns |
| `engineer` | Language skill for your stack | Idioms, conventions, GREEN phase |
| `refactorer` | Refactoring skill + documentation skill | Smell catalog, safe refactoring, code documentation |
| `documenter` (optional) | Documentation skill | ADRs, design docs (post-completion only) |

Example for the tester prompt:

```markdown
## Before Starting (MANDATORY)
Read the testing skill for your project's stack before your first edit.

Consult skill references on-demand when the task involves specific areas.
```

The domain skills vary by project stack. The orchestration rules in this reference do not -- they apply regardless of language.

## Task Assignment Protocol

Send ONE message per task assignment containing ALL of:

1. Task number and subject
2. Files to read for context
3. What the agent should produce
4. Who to message when done (use exact name from directory)

Example:

```
Task #2: Write failing test for `Investigation.close/1`
Read: lib/lakitu/investigation.ex (lines 40-65)
Produce: test in test/lakitu/investigation_test.exs asserting that
  close/1 sets status to :closed and records closed_at timestamp
When done: message `team-lead` with the test file path and failure output
```

Before sending an assignment:
- Check if the agent already sent you a completion message
- If so, acknowledge their work instead of re-assigning

Do NOT send a brief "start" followed by a detailed message.
Do NOT send the same assignment twice.

## While Agents Work

After assigning work, messages from agents arrive AUTOMATICALLY.

Do NOT:
- Poll or check on agent status
- Send "still waiting" messages
- Generate turns to narrate the wait
- Use tools to check agent output files

Instead:
- Prepare upcoming tasks (create in task list, draft descriptions)
- Review completed work from previous phases
- End your turn -- the next agent message will wake you

Every polling turn re-consumes the full context window and produces nothing.

## Error Recovery

**Silent agent** (no response within 5 minutes):

1. Send a single status-check message to the agent
2. If still no response after the check, re-send the assignment

**Agent failure** (agent reports an error or crashes):

1. Document completed and remaining work in the task list
2. Re-spawn ONLY the failed agent with the same prompt
3. Assign the failed agent's pending task to the new instance
4. Do NOT restart the entire team for a single agent failure

**Session recovery** (resuming after a full session failure):

1. Read the task list to identify completed vs. remaining work
2. Create a new team with the same structure
3. Skip completed tasks -- assign only remaining work
4. Note in agent prompts which files already exist from prior work

## TDD Cycle Flow

```
+----------+     +----------+     +------------+
| tester   |---->| engineer |---->| refactorer |
| (RED)    |     | (GREEN)  |     | (REFACTOR) |
+----------+     +----------+     +------------+
     ^                                  |
     +----------------------------------+
                 next task
```

Each task goes through one full cycle:

1. `tester` writes a failing test, confirms it fails, messages `engineer`
2. `engineer` writes minimal code to pass, confirms green, messages `refactorer`
3. `refactorer` improves code quality, writes/updates code-level docs (module headers, function docs, inline comments), keeps tests green, messages `tester`
4. `tester` applies any test-side suggestions from `refactorer`
5. Task marked completed; next task begins at step 1

The team-lead assigns work to `tester` to start each cycle and monitors phase transitions through automatic message delivery.

## Documentation in the TDD Cycle

### Code-Level Docs (Every Cycle)

The refactorer writes/updates module headers, function docs, and inline comments as part of the REFACTOR phase.

### Engineer's Lightweight Responsibility

The engineer adds doc stubs (e.g., `@doc`/JSDoc) on new public functions during GREEN -- interface description only, one line. The refactorer polishes these during REFACTOR.

### Architecture Docs (Optional, Post-Completion)

After all tasks complete, the team-lead evaluates whether the feature warrants architecture docs (ADR, design doc). If yes, the team-lead spawns a one-shot `documenter` agent to produce the doc. This does NOT happen per-cycle.

### When to Skip Architecture Docs

Single-function changes, bug fixes, internal refactors. Architecture docs are for new modules, non-obvious design decisions, or significant behavioral changes.

## Guidelines

### Do

- Create all tasks in the task list before spawning agents
- Spawn all three agents in a single message (parallel tool calls)
- Wait for agent messages -- they arrive automatically
- Track task status through phases
- Keep agent prompts focused: identity + team directory + role instructions
- Acknowledge agent completion messages before assigning new work
- Include documentation skill reference in refactorer prompt
- Have engineer add minimal doc stubs on new public functions
- Evaluate need for architecture docs after all tasks complete

### Don't

- Spawn agents without `mode: "acceptEdits"`
- Omit the Team Directory block from any agent prompt
- Send multiple messages for one assignment
- Poll, narrate waiting, or generate idle turns
- Restart the entire team when one agent fails
- Assign work outside an agent's file scope (see Team Roles table)
- Use agent UUIDs -- always use names (`tester`, `engineer`, `refactorer`)
- Spawn a dedicated documenter for every cycle (overkill)
- Skip doc updates when refactoring changes signatures or behavior
- Write architecture docs mid-cycle (wait for full picture)
