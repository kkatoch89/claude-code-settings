# Command: Write

Write a single user story with BDD acceptance criteria.

## Usage

`/writing-agile-stories write` or `/writing-agile-stories write [user need description]`

## When to Use

- Defining a single user need or feature
- Converting a requirement into a testable story
- Creating a ticket with acceptance criteria
- User asks to "write a story" or "create acceptance criteria"

## Process

### Phase 1: Discovery

Understand the user need before writing anything.

**Questions to ask (2-3 at a time):**

Round 1 - Actor & Context:
- Who experiences this need? (their situation/role in the domain)
- What situation or event triggers this need?

Round 2 - Outcome & Value:
- What outcome do they want to achieve?
- How will they know they succeeded?

Round 3 - Boundaries & Failures:
- What constraints or business rules apply?
- What could go wrong? How should failures be handled?

Round 4 - Domain Language:
- What terms does the business use for these concepts?
- Are there terms that might be ambiguous?

**Discovery output:**
```
Understanding: [1-2 sentence summary]
Actor: [Who] | Trigger: [What prompts this]
Outcome: [What they achieve] | Constraints: [Rules]
Failure Modes: [What could go wrong]
Domain Terms: [Key vocabulary]
```

Confirm understanding before proceeding.

### Phase 2: Story Drafting

Write a narrative-form story:

```markdown
## Story: [Descriptive Title]

[2-4 sentence narrative describing:
 - The user's situation
 - The behavior they need
 - The value they get
Written in domain language, present tense]

### Context
[When this behavior is relevant -- the business preconditions]
```

**Guidelines:**
- Describe the situation that creates the need
- Focus on observable behavior
- Use domain language consistently
- Keep it small enough for one iteration
- Do NOT use "As a [user], I want [X], so that [Y]" template
- Do NOT include implementation details

Get feedback before writing criteria.

### Phase 3: Acceptance Criteria

Define testable scenarios using Given-When-Then format.

**Scenario types required:**
1. **Happy path** -- The primary success scenario
2. **Alternative paths** -- Valid variations with different outcomes
3. **Failure modes** -- How errors are handled gracefully

```markdown
### Acceptance Criteria

#### Scenario: [Description]
- Given [business context/state]
- When [user action or system event]
- Then [observable outcome]
- And [additional outcomes if needed]
```

**Guidelines:**
- Use business language in Given-When-Then
- Focus on observable outcomes
- Include concrete examples
- Make each scenario independently testable
- Do NOT reference implementation details
- Do NOT write scenarios that depend on each other

Outline scenario types first, confirm coverage, then write details.

### Phase 4: Review

Validate against quality criteria:

| Check | Anti-Pattern to Avoid |
|-------|----------------------|
| Behavior-focused | Implementation details, feature lists |
| Domain language only | "user clicks", "API returns" |
| Narrative form | "As a [user], I want..." template |
| Small & testable | Epic-sized, vague outcomes |
| Failure modes included | Only happy path scenarios |
| Scenarios independent | Scenarios requiring sequence |

**Review questions:**
1. Can a developer write tests directly from these scenarios?
2. Can a business stakeholder understand every term?
3. Is each scenario independently verifiable?
4. Are all failure modes covered?
5. Is the story small enough for one iteration?

## Handling Edge Cases

### User Provides Implementation-Focused Requirements

Reframe toward behavior:
- "What outcome does the user want from this button/API/feature?"
- "If we ignore how it's built, what should the user experience?"

### Discovery Reveals an Epic

When a "story" is too large:
1. Acknowledge it's epic-sized
2. Propose 3-5 smaller stories
3. Ask which to write first
4. Note dependencies between stories

### Unclear When Story is "Done"

A story is ready when:
- All quality checks pass
- User confirms criteria are complete
- Scenarios are testable without implementation knowledge

## Next Steps

After the story is complete:
- **Write related story** -- Start a new story with shared context
- **Break down into tasks** -- Use `decompose` to create implementation tasks
- **Done** -- End workflow

## References

- [examples.md](../references/examples.md) -- Complete story examples
- [anti-patterns.md](../references/anti-patterns.md) -- Common mistakes
- [templates.md](../references/templates.md) -- Output templates
- [thinking-patterns.md](../references/thinking-patterns.md) -- Structured reasoning by phase
