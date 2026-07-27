---
name: researching-codebase
description: "Researches and documents existing codebase implementations. Use when exploring how code works, understanding architecture, answering 'how does X work?' questions, or gathering context before making changes. Produces structured research documents with code references."
---

# Research Codebase

Conduct comprehensive research across the codebase to answer questions by exploring files, understanding patterns, and synthesizing findings.

## When This Skill Applies

- Exploring existing implementations before making changes
- Understanding architecture or system design
- Answering "how does X work?" questions about the codebase
- Documenting component interactions and data flows
- Gathering historical context from documentation
- User asks to "research", "document", or "understand" something

## Critical Principle

**Focus on documentation.** Your primary job is to explain the codebase as it exists today.

- Describe what exists, where it exists, how it works, and how components interact
- You are creating a technical map/documentation of the existing system
- Only suggest improvements or identify problems if explicitly asked

---

## Decomposition Phase

**Goal**: Understand the research context and break down the question.

### Step 1: Read Mentioned Files

If the user mentions specific files (tickets, docs, JSON):
- Read them fully using the Read tool without limit/offset parameters
- **CRITICAL**: Read these files yourself in the main context before beginning research
- This ensures you have full context before decomposing the research

### Step 2: Analyze and Decompose

- Break down the user's query into composable research areas
- Identify specific components, patterns, or concepts to investigate
- Consider which directories, files, or architectural patterns are relevant
- Create a research plan to track all subtasks

### User Confirmation

Present your understanding of the research question and decomposition, then confirm:

- Does this capture the research question correctly?
- Options: proceed with research, adjust the scope, or let the user clarify

---

## Research Phase

**Goal**: Explore the codebase to gather information systematically.

### Research Strategy

**For codebase research:**
- **Navigation**: Find WHERE files and components live using Glob and directory exploration
- **Analysis**: Understand HOW specific code works by reading relevant files
- **Pattern finding**: Find examples of existing patterns using Grep

**For documentation:**
- **Locate**: Discover what documents exist about the topic
- **Analyze**: Extract key insights from the most relevant documents

### Research Guidelines

- Start with broad searches to find what exists
- Then dive deep into the most relevant findings
- Search for different things in parallel when possible
- **Focus on documenting, not evaluating or improving**

### Important

- Complete ALL research before proceeding to Synthesis Phase
- Describe what exists without suggesting improvements

---

## Synthesis Phase

**Goal**: Compile findings and generate the research document.

### Step 1: Synthesize Findings

- Compile all findings from codebase and documentation exploration
- Prioritize live codebase findings as the primary source of truth
- Use documentation findings as supplementary historical context
- Connect findings across different components
- Include specific file paths and line numbers for reference
- Highlight patterns, connections, and architectural decisions
- Answer the user's specific questions with concrete evidence

### Step 2: Generate Research Document

Write the document using the template at [references/research-template.md](references/research-template.md).

**Required sections**:
- Research Question and Summary
- Detailed Findings with `file:line` references
- Code References for quick navigation
- Architecture Documentation
- Historical Context (if relevant documentation found)
- Open Questions for areas needing follow-up

### Step 3: Add GitHub Permalinks (if applicable)

- Check if on main branch or if commit is pushed: `git branch --show-current` and `git status`
- If on main/master or pushed, generate GitHub permalinks:
  - Get repo info: `gh repo view --json owner,name`
  - Create permalinks: `https://github.com/{owner}/{repo}/blob/{commit}/{file}#L{line}`
- Replace local file references with permalinks in the document

### User Review

Present a summary of the document. Ask whether it addresses the question, needs more detail on specific areas, or if there are follow-up questions.

---

## Follow-up Phase

**Goal**: Present findings and handle additional questions.

### Present Findings

- Present a concise summary of findings to the user
- Include key file references for easy navigation
- Ask if they have follow-up questions or need clarification

### Handle Follow-up Questions

If the user has follow-up questions:
- Append to the same research document
- Add a new section: `## Follow-up Research`
- Conduct additional investigation as needed
- Continue updating the document

### Next Action

Offer the user options for next steps:
- Follow-up question: handle follow-up and update document
- Start related research: begin new research with shared context
- Done: end workflow

---

## Anti-Patterns

### Suggesting Improvements
```
BAD:  "The authentication flow could be simplified by..."
BAD:  "This would benefit from refactoring..."

GOOD: "The authentication flow works by first checking..."
GOOD: "This module handles X by doing Y..."
```

### Critiquing Implementation
```
BAD:  "This is a problematic pattern because..."
BAD:  "The code has issues with..."

GOOD: "The current implementation uses this pattern..."
GOOD: "The code handles this case by..."
```

### Missing Concrete References
```
BAD:  "The system handles authentication somewhere in the codebase"

GOOD: "Authentication is handled in `src/auth/handler.ts:45-89`"
```

### Placeholder Values
```
BAD:  Writing document with "[TBD]" or placeholder metadata

GOOD: Always gather complete information before writing the document
```

---

## Troubleshooting

**Search returns empty results:**
- Verify the search terms match what's in the codebase
- Try broader search terms
- Check if the component exists at all using Glob

**Research scope too broad:**
- Narrow to specific components or files
- Break into multiple focused research sessions
- Ask user to prioritize which aspect to investigate first

---

## Example Session

**User**: `How does user authentication work in this app?`

**Decomposition Phase output:**
```
I'll research the authentication flow by investigating:
1. Entry points (login routes, middleware)
2. Token/session management
3. User validation logic
4. Protected route enforcement

Research plan:
- Search for authentication-related files
- Read and analyze the auth module
- Trace the authentication flow end-to-end
```

**Synthesized finding excerpt:**
```
## Authentication Flow

### Entry Point
Login requests hit `src/routes/auth.ts:23-45`, which validates
credentials against the User model.

### Session Management
Sessions are stored in Redis via `src/lib/session.ts:12`. The
`createSession()` function generates a JWT with 24h expiry.

### Protected Routes
The `requireAuth` middleware (`src/middleware/auth.ts:8-34`)
checks the Authorization header and validates the JWT signature.
```

---

## Critical Rules

1. Read mentioned files before beginning research
2. Complete all research before synthesizing
3. Never use placeholder values
4. Describe what exists without critiquing or suggesting improvements

---

## Integration with Other Skills

### Before Implementation
Research feeds into planning or implementation workflows:
- Research documents WHAT exists
- Plans document HOW to change it

### With Thinking Patterns
For complex research:
- `atomic-thought`: Decompose research question into parts
- `graph-of-thoughts`: Synthesize findings from multiple sources
- `chain-of-thought`: Trace execution paths through code
