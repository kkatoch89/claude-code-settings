# Elephant Carpaccio Slicing

Break features into the thinnest possible vertical slices -- each one cutting across all necessary layers (UI, logic, data) to produce an independently working, testable, demoable increment.

## Core Concept

The output is an ordered slice backlog, not implementation. Each slice delivers user-visible value.

## Slice Validity Rules

Every slice MUST pass ALL of these tests:

- **Vertical** -- Cuts through all necessary layers, not just backend or just frontend in isolation
- **Working** -- After this slice, the system is in a testable, demoable state. Tests pass.
- **Distinct** -- A stakeholder can see something changed compared to the previous slice
- **Valuable** -- Delivers more user value or reduces more risk than the last slice
- **Small** -- Implementable in a single focused coding pass

## Architecture Detection

Before slicing, determine the repository structure:

| Type | Description | Slice Atomicity |
|------|-------------|-----------------|
| **Single repo** | All layers in one repository | Slices are atomic |
| **Monorepo** | Multiple packages/apps in one repo | Slices can touch multiple packages but are atomic |
| **Multi-repo** | Separate repos with independent CI/deploy | Slices are coordinated across repos |

For multi-repo setups, identify:
- Which repo you are currently operating in
- Contract surface between repos (REST API, GraphQL schema, RPC definitions, shared types)
- Which repo deploys first in practice (typically backend)
- Whether a shared types/contract package exists

## Ordering Principles

- **Slice 1 is always a walking skeleton** -- the thinnest possible end-to-end path proving the architecture connects. Hard-code values if needed. Its value is pure risk reduction.
- Core happy-path functionality comes next, one thin layer at a time.
- Prefer simpler implementations that deliver value faster (e.g., accept user input directly before building lookup tables).
- Legal/compliance requirements before nice-to-haves.
- All core paths before any single path is polished.
- Validation, error handling, and edge cases LAST.
- UI polish and optimization LAST.

## Slicing Heuristics

When a slice feels too large, split it further:

| Heuristic | Strategy |
|-----------|----------|
| **By workflow path** | One user flow end-to-end before the next |
| **By data variation** | Start with one data type or category, add others as separate slices |
| **By business rule** | Simplest rule first, add complexity in later slices |
| **By interface** | One platform, device, or UI variant first |
| **Simple before complex** | Happy path across all paths before edge cases on any single path |
| **Hardcode then generalize** | Hardcode a value in slice N, replace with dynamic logic in slice N+1 |

## Multi-Repo Slicing

When slicing across repository boundaries:

- **Contract-first** -- Each slice that crosses a repo boundary defines the API contract as its first sub-step
- **Thinnest crossing** -- Minimize the API surface introduced per slice. One endpoint, one field, one query.
- **Upstream before downstream** -- The side that provides the contract is built first
- **Mock strategy** -- When the upstream won't be deployed before the downstream is built, note that a temporary mock of the agreed contract shape should be used

## Anti-Patterns

If you catch yourself producing any of these, re-slice:

| Anti-Pattern | Why It's Wrong |
|--------------|----------------|
| **Horizontal slices** | Backend-only or frontend-only chunks deliver no user-visible value until a later slice integrates them |
| **Build all endpoints then all UI** | The most common multi-repo anti-pattern -- horizontal slicing in disguise |
| **Gold-plating early slices** | Adding validation/error handling/polish to slice 2 when core paths in slices 8-12 don't exist yet |
| **Speculative infrastructure** | Abstractions or frameworks beyond what the current slice requires |
| **Task decomposition as slices** | "Set up the database" and "write the migration" are tasks within a slice, not slices themselves -- each slice must have user-visible value |

## Output Format

```markdown
## Slice Backlog: [Feature Name]

Architecture: [single-repo | monorepo | multi-repo]

1. **Walking skeleton** -- [thinnest end-to-end path].
   Value: Proves architecture connects end-to-end.
   [Repos: backend, frontend]  <!-- only for multi-repo -->

2. **[Slice name]** -- [one-line description of what changes].
   Value: [what a stakeholder can now see or do].

3. ...
```

## Blocked Repo Planning

If you only have access to one repo in a multi-repo setup, still plan full vertical slices. For each slice, note what the inaccessible repo needs to do as a companion task.
