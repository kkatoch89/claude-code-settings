---
name: writing-documentation
description: |
  Writes documentation for two audiences: human developers and LLMs. Covers three
  doc types: code-level docs (module headers, function docs, inline comments),
  architecture docs (ADRs, design docs, system overviews), and project docs
  (READMEs, guides, CLAUDE.md). Language-agnostic. Includes post-processing
  for human-readable prose.

  Use when asked to "document", "add docs", "write a README", "create an ADR",
  "add module docs", "document this function", "write architecture docs",
  "create a getting started guide", "write CLAUDE.md", or "add comments".
---

# Writing Documentation

Write documentation that serves two audiences: human developers who need to understand and use code, and LLMs that need to retrieve, chunk, and reason about code.

## Quick Start

Provide a code reference (file, module, function) or describe what needs documenting:

```
"Document the auth module in lib/my_app/auth/"
"Write an ADR for choosing PostgreSQL"
"Create a README for this project"
"Add function docs to UserController"
"Write a getting started guide"
```

## Doc Type Router

Detect the doc type from the request, then follow the matching command workflow.

| Signal in Request | Doc Type | Command |
|-------------------|----------|---------|
| file path, function name, "add docs", "add comments", "docstring" | Code-Level | `commands/code-level.md` |
| "ADR", "design doc", "architecture", "system overview" | Architecture | `commands/architecture.md` |
| "README", "getting started", "CLAUDE.md", "guide" | Project | `commands/project.md` |

**If ambiguous**: Default to code-level when given a file path, architecture when given a system description, project when given a project path.

## Utility Commands

| Signal in Request | Command |
|-------------------|---------|
| "diagnose", "check readability", "audit this doc" | `commands/diagnose.md` |
| "rewrite", "simplify this", "make this readable" | `commands/rewrite.md` |

## Dual-Audience Principles

### For Human Developers

Based on Ousterhout's "A Philosophy of Software Design" (see `references/ousterhout-principles.md`):

- Reduce cognitive load — make the reader's job easier, not harder
- Separate interface from implementation — document WHAT, not HOW
- Document non-obvious things — skip what the code already says
- Use documentation as a design tool — writing docs reveals design problems
- Document cross-module interactions — not just individual components
- Low-level comments add precision; high-level comments provide intuition

### For LLMs

Based on retrieval and chunking patterns (see `references/llm-doc-patterns.md`):

- Consistent structure — same heading hierarchy across docs of the same type
- Explicit headings — keyword-rich, not generic
- Front-loaded context — most important information first (BLUF)
- Self-contained sections — each section understandable when extracted
- Explicit relationships — state dependencies by fully qualified name
- Grep-friendly identifiers — consistent naming, full qualified names
- No ambiguous pronouns — use explicit nouns across chunk boundaries

## Post-Processing for Human-Readable Prose

User-facing prose (READMEs, guides, tutorials) should be post-processed for readability. See `references/writing-for-humans.md` for the full methodology.

**Apply to**: READMEs, getting started guides, tutorials
**Do NOT apply to**: Code-level docs, architecture docs, CLAUDE.md, agent instructions

### Quick Rules

1. **BLUF** — Lead with the conclusion, recommendation, or action
2. **Active voice** — The subject acts. 80%+ of sentences should use active voice
3. **Cut filler** — Remove banned words (delve, leverage, robust, utilize, facilitate)
4. **Short paragraphs** — 2-4 sentences max
5. **Specific headings** — Not "Overview" or "Details" — make headings answer questions
6. **30-50% reduction** — Aim to cut word count by a third to half

## Anti-Patterns

- Restating the code in comments ("increment counter" above `counter += 1`)
- Generic headings ("Overview", "Details", "Miscellaneous")
- Implementation details in interface docs ("uses a hash map internally")
- Ambiguous pronouns across section boundaries ("it handles this by...")
- Documentation longer than the code it describes (for code-level docs)
- Prose in agent instructions (CLAUDE.md should be directives, not paragraphs)

## References

| Reference | When to Load |
|-----------|--------------|
| `references/ousterhout-principles.md` | When deciding what to document and at what level of detail |
| `references/llm-doc-patterns.md` | When structuring docs for retrieval and chunking |
| `references/writing-for-humans.md` | When post-processing user-facing prose |
| `references/llm-anti-patterns.md` | When diagnosing why text reads like AI output |
| `references/conciseness-techniques.md` | When editing for maximum word count reduction |
