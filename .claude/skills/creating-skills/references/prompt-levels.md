# The Seven Levels of Prompt Sophistication

Each level builds on the previous. Most work happens at levels 2-4.

## Level 1: High-Level Prompt

Static, ad-hoc prompts for repeat work. Contains 1-3 sections: Title, Purpose, and a simple instruction.

**When to use:** One-off tasks you repeat. "Three times marks a pattern -- copy whatever you're doing and write it as a high-level prompt."

**Builds on:** Nothing -- this is the foundation.

### Example

```markdown
# Start Development Server

Start the application for development.

1. Navigate to the application directory: `cd apps/my_app`
2. Install dependencies (if needed): `bun install`
3. Start the development server: `bun run dev`
4. Open your browser to: http://localhost:5173/
```

### Characteristics

- No dynamic variables
- No metadata section needed
- Direct, actionable instructions
- Great place to start, terrible place to end

### When to Level Up

Move to Level 2 when you need inputs that change between runs, want structured output, or the task has distinct phases.

---

## Level 2: Workflow Prompt

Sequential workflow with the **Input -> Workflow -> Output** pattern. This is the most important level -- the workflow section is where the real power lives.

**When to use:** Any task requiring multiple steps executed in order.

**Builds on:** Level 1 + adds Variables, Workflow, Report sections.

### Example

```markdown
---
allowed-tools: Read, Write, Edit, Glob, Grep
description: Creates a concise implementation plan
argument-hint: [user prompt]
---

# Quick Plan

Create a detailed implementation plan based on the user's requirements.

## Variables

USER_PROMPT: $ARGUMENTS
PLAN_OUTPUT_DIRECTORY: `specs/`

## Instructions

- Carefully analyze the user's requirements
- Create a concise implementation plan
- Generate a descriptive, kebab-case filename

## Workflow

1. Analyze Requirements - Parse USER_PROMPT thoroughly
2. Design Solution - Develop technical approach
3. Document Plan - Structure a comprehensive markdown document
4. Save & Report - Write the plan to PLAN_OUTPUT_DIRECTORY

## Report

After creating the plan, provide a concise report with the file path.
```

### Variable Syntax

```markdown
## Variables

DYNAMIC_VAR: $ARGUMENTS           # Full argument string
FIRST_ARG: $1                     # Positional argument
SECOND_ARG: $2                    # Positional argument
STATIC_VAR: `some/fixed/path/`    # Hardcoded value
WITH_DEFAULT: $2 or 3 if not provided
```

### When to Level Up

Move to Level 3 when you need conditional logic, loops, or early returns for validation.

---

## Level 3: Control Flow Prompt

Adds conditionals, loops, and early returns to the workflow.

**When to use:** Tasks with branching logic, iteration, or validation requirements.

**Builds on:** Level 2 + adds control flow structures in Workflow.

### Control Flow Patterns

**Early Return / Validation:**
```markdown
- If no PATH_TO_PLAN is provided, STOP immediately and ask the user to provide it.
- Check prerequisites and STOP immediately if missing:
  - API_TOKEN must be set
  - Required command must be available
```

**Conditionals:**
```markdown
- If the file exists, read and update it. Otherwise, create a new file.
- IMPORTANT: If authentication fails, abort immediately and report the error.
```

**Loops with XML Tags:**
```markdown
- IMPORTANT: For each item in the list, execute the following:

<process-loop>
  - Extract the item details
  - Process the item
  - Save results
  - Report progress
</process-loop>
```

### Characteristics

- **Conditionals**: `If X, STOP immediately` or `If X, do Y. Otherwise, do Z.`
- **Loops**: Named XML sections like `<image-loop>`
- **Early returns**: Validation before expensive operations
- **IMPORTANT keyword**: Signals critical instructions to the agent

### When to Level Up

Move to Level 4 when you need multiple agents working in parallel, background execution, or specialized sub-agents.

---

## Level 4: Delegation Prompt

Kicks off other agents to do work. Your primary agent becomes a prompt engineer for sub-agents.

**When to use:** Tasks that benefit from parallelization, background execution, or specialized agents.

**Builds on:** Level 3 + adds agent spawning and orchestration.

### Key Concepts

**Agents Are Stateless:** Sub-agents have no context from the primary agent. Every sub-agent prompt must be self-contained:
- Include all necessary context
- Specify exact expectations
- Define output format

**Parallel vs Sequential:**
- **Parallel**: Use when tasks are independent. Spawn N agents simultaneously via Task tool.
- **Sequential**: Use when tasks depend on each other. Launch first agent, use result for second.

### Agent Configuration

Pass configuration through:
- Model selection (`--model sonnet`)
- Tool restrictions (`allowed-tools:`)
- System prompt modifications (`--append-system-prompt`)

### When to Level Up

Move to Level 5 when you want to decouple planning from execution, or the same execution prompt should work with different inputs.

---

## Level 5: Higher-Order Prompt

Accepts another prompt (file) as input. Provides consistent structure while the input varies.

**When to use:** Decoupling planning from execution. Same prompt works with different plan inputs.

**Builds on:** Levels 2-4 + accepts prompt files as input parameters.

### The Power of Higher-Order Prompts

The **plan** prompt creates a specification file. The **build** prompt consumes any specification file. They are independent -- you can use different planners with the same builder.

### Modular Workflow Chains

```
/quick-plan "Add user authentication"
  -> specs/add-user-auth.md

/build specs/add-user-auth.md
  -> Implementation

/review specs/add-user-auth.md
  -> Code review against spec
```

### Characteristics

- **Prompt file as input**: `$ARGUMENTS` points to a plan/spec file
- **Flexible**: Same execution prompt works with any compatible input
- **Enables modularity**: Plan -> Build -> Review chains
- **Reusable infrastructure**: The higher-order prompt is stable; inputs vary

### When to Level Up

Move to Level 6 when you want to generate new prompts programmatically or have consistent prompt formats to template.

---

## Level 6: Template Meta-Prompt

A prompt that creates other prompts in a specific format. The most powerful prompt you can write.

**When to use:** Scaling prompt creation. Once you have consistent formats, template their generation.

**Builds on:** All previous levels + adds Template section for prompt generation.

### The Template Section

The Template (or "Specified Format") section is the key differentiator:
- Defines exact structure of generated artifacts
- Uses `<placeholder>` syntax for variable parts
- Agent fills in placeholders based on context

### Placeholder Patterns

```markdown
<name_of_prompt>           # Derive from context
<comma separated>          # Format instruction
<one-line description>     # Length constraint
{VARIABLE_NAME}            # Reference a variable
<simple|medium|complex>    # Enumerated options
```

### Why This Is Powerful

Once you have this:
1. Your prompt format is codified
2. New prompts follow consistent structure
3. Team members generate compatible prompts
4. You scale prompt creation with compute

### When to Level Up

Move to Level 7 when you want prompts that accumulate knowledge, or you are building domain experts that learn.

---

## Level 7: Self-Improving Prompt

Prompts with an **Expertise** section that gets updated over time. Creates feedback loops where implementations feed back into planning knowledge.

**When to use:** Domain experts that should accumulate knowledge. Systems that learn from their work.

**Builds on:** All previous levels + adds Expertise section that grows.

### The Expert Family Pattern

Self-improving prompts work in families of three:

- **Expert Plan** (designs) -> creates specification using current Expertise
- **Expert Build** (implements) -> implements using its Expertise
- **Expert Improve** (learns) -> reviews work, extracts learnings, updates Expertise

### The Expertise Section

```markdown
## Expertise

### Category Name

- Specific knowledge point
- Another knowledge point
- Pattern discovered from implementation

### Another Category

- More accumulated knowledge
```

**Rules for Expertise:**
- Organized into logical categories
- Contains concrete, actionable knowledge
- Updated ONLY by the Improve prompt
- Never modified during normal execution

### The Self-Improvement Cycle

1. **Plan** creates specification using current Expertise
2. **Build** implements using its Expertise
3. **Improve** reviews work, extracts learnings
4. **Improve** updates Plan and Build Expertise sections
5. Next iteration benefits from accumulated knowledge

### When to Use Level 7

- Domain experts for specific technologies
- Systems that should learn from experience
- Teams wanting to capture and share knowledge
- Complex domains with evolving best practices

---

## Choosing the Right Level

```
What does your prompt need?
|-- Simple repeat task -> Level 1
|-- Sequential steps -> Level 2
|-- Conditionals/loops -> Level 3
|-- Multiple agents -> Level 4
|-- Plan as input -> Level 5
|-- Generate prompts -> Level 6
+-- Learn over time -> Level 7
```

**Key principle:** Start at the lowest level that solves the problem. Most prompts are Level 2-4. Reach for Level 5+ only when needed.

## System Prompts vs User Prompts

| Aspect | System Prompt | User Prompt |
|--------|---------------|-------------|
| Scope | Rules for ALL conversations | Instructions for ONE task |
| Persistence | Cannot change mid-conversation | Changes with each invocation |
| Mistakes | Scale to every user prompt | Isolated to single run |

**System prompts** (agent personality): Use Purpose, Instructions, Examples. Avoid prescriptive workflows.

**User prompts** (reusable commands): Use full section toolkit. This is 90% of what you will write.

## Common Mistakes

- **Over-engineering**: Starting at Level 5+ when Level 2 suffices
- **Section bloat**: Adding sections "just in case" -- each must earn its place
- **Wrong prompt type**: Writing workflows for system prompts (use Purpose/Instructions instead)
- **Missing context**: Sub-agent prompts that assume shared state (they are stateless)
- **Vague workflows**: Steps like "analyze the code" instead of specific actions
