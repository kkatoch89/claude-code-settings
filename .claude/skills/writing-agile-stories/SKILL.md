---
name: writing-agile-stories
description: "Full story lifecycle: slice features into thin vertical increments, write behavior-focused user stories with BDD acceptance criteria, and decompose stories into implementation tasks. Use when planning features, defining requirements, creating development tickets, writing acceptance criteria, slicing epics, or breaking stories into tasks."
---

# Writing Agile Stories

Manage the full story lifecycle from feature to implementation-ready tasks. This skill covers three activities:

1. **Slice** -- Break features into thin vertical increments using Elephant Carpaccio methodology
2. **Write** -- Create behavior-focused user stories with BDD-style acceptance criteria
3. **Decompose** -- Break stories into small, actionable implementation tasks

## Commands

| Command | Purpose | When to Use |
|---------|---------|-------------|
| `/writing-agile-stories slice` | Slice a feature into thin vertical stories | Feature spans multiple layers or components |
| `/writing-agile-stories write` | Write a single user story with BDD criteria | Defining a specific user need |
| `/writing-agile-stories decompose` | Break a story into implementation tasks | Story is ready for sprint planning |

See the `commands/` directory for detailed instructions for each command.

## When This Skill Applies

- Planning a new feature that spans multiple layers
- Defining new features or user needs
- Clarifying requirements before implementation
- Creating tickets for development work
- Converting vague requirements into testable specifications
- Breaking down stories for sprint planning
- User asks to "write a story", "slice a feature", "create acceptance criteria", or "break down a story"

## Core Principles

1. **Behavior over Implementation**: Describe what users experience, not how it's built
2. **Narrative over Template**: Use prose, NOT "As a [user], I want [feature], so that [benefit]"
3. **Concrete over Abstract**: Use specific examples (Specification by Example)
4. **Vertical over Horizontal**: Every slice cuts through all necessary layers
5. **Conversation Starter**: Stories facilitate discussion, not replace it
6. **Ubiquitous Language**: Use terms from the problem domain, not technical jargon

## Typical Workflow

```
Feature  -->  Slice (Carpaccio)  -->  Write (BDD Stories)  -->  Decompose (Tasks)
                                      for each slice             for each story
```

Not every engagement starts at the beginning. Enter the workflow at the appropriate point:

- **Have a feature/epic?** Start with `slice`
- **Have a scoped user need?** Start with `write`
- **Have a story with acceptance criteria?** Start with `decompose`

## Quick Start

### Slicing a Feature

```markdown
## Slice Backlog: [Feature Name]

1. **Walking skeleton** -- [thinnest end-to-end path]. Value: proves architecture connects.
2. **[Next slice]** -- [description]. Value: [what stakeholder can now see/do].
3. ...
```

### Writing a Story

```markdown
## Story: Customer Cancels Order Before Shipment

When customers change their mind about a purchase, they need to cancel it
and receive confirmation that their refund is being processed. This must
happen before the order ships, since the returns process applies afterward.

### Context
Available for orders in "confirmed" or "processing" status.

### Acceptance Criteria

#### Scenario: Successful cancellation
- Given a customer has an order in "confirmed" status
- When they request to cancel the order
- Then the order status changes to "cancelled"
- And a refund is initiated for the full order amount

#### Scenario: Order already shipped
- Given an order has left the warehouse
- When the customer attempts to cancel
- Then they are informed cancellation is unavailable
- And they are directed to the returns process
```

### Decomposing a Story

```markdown
## Tasks for: [Story Title]

- [ ] Task description
- [ ] Task description -- (context: why this matters)
...
```

## Reference Files

| Reference | Content |
|-----------|---------|
| [examples.md](references/examples.md) | Complete story examples with discovery and criteria |
| [anti-patterns.md](references/anti-patterns.md) | Common mistakes with corrections |
| [templates.md](references/templates.md) | Output templates and canonical example |
| [thinking-patterns.md](references/thinking-patterns.md) | Structured reasoning by phase |
| [slicing-carpaccio.md](references/slicing-carpaccio.md) | Elephant Carpaccio slicing methodology |
| [task-decomposition.md](references/task-decomposition.md) | Story-to-task decomposition methodology |

## Anti-Patterns Quick Reference

- **Template smell**: "As a user, I want..." -- use narrative prose instead
- **Implementation leak**: Technical details in stories -- describe behavior, not code
- **Vague outcomes**: "handles appropriately" -- use specific, testable outcomes
- **Missing failures**: Happy path only -- include error and edge case scenarios
- **Giant stories**: Too much in one story -- slice or split
- **Horizontal slices**: Backend-only or frontend-only -- every slice must be vertical
- **Standalone test tasks**: Tests are implicit in every implementation task (TDD)

See [anti-patterns.md](references/anti-patterns.md) for detailed examples.

## Integration with Other Skills

### Upstream
- `writing-product-briefs` -- Produces north star scenarios that feed into slicing
- `writing-prds` -- Use case compendium provides requirements to slice and write stories for

### Downstream
- Implementation planning -- Stories and tasks define what to build
- Jira/ticket management -- Stories become tickets with acceptance criteria as checklists
