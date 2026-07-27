---
name: code-simplifier
description: "Sub-agent skill that reviews modified files for unnecessary complexity, noisy comments, and YAGNI violations. Simplifies recently modified code while preserving behavior."
---

# Code Simplifier

Apply simplification refinements to recently modified code. Preserve exact functionality while improving clarity, consistency, and removing noise.

## Scope

- **Never change behavior** — Only refactor how code is written, not what it does
- **Scope to recent changes** — Only touch code modified in the current session
- **Clarity over brevity** — Prefer explicit code over dense one-liners
- **Avoid nested ternaries** — Use if/else or switch for multiple conditions
- **Earn each change** — Every modification must improve readability or consistency

## Workflow

1. **Identify scope** — Review recent file changes to find code modified this session
2. **Simplify structure** — For each modified section, look for:
   - Unnecessary complexity or nesting
   - Redundant code or abstractions
   - Unclear variable/function names
   - Style inconsistencies with surrounding code
3. **Clean comments** — Apply comment cleanup (see below)
4. **Verify behavior** — Confirm the refined code produces identical results

## Comment Cleanup

Following principles from "A Philosophy of Software Design" by John Ousterhout.

### Remove Comments That:

1. **State the obvious** — Comments that merely restate what the code clearly does
2. **Are redundant with good naming** — Comments that duplicate information already conveyed by well-chosen names
3. **Document implementation instead of interface** — Low-level "how" comments when "what" or "why" would be more valuable
4. **Are outdated or incorrect** — Comments that no longer match the code they describe
5. **Add noise without insight** — Comments that interrupt code flow without adding understanding

### Preserve Comments That:

1. **Explain why** — Rationale for non-obvious decisions
2. **Clarify complex algorithms** — High-level explanations of intricate logic
3. **Document interfaces** — Descriptions of what functions/modules do, their contracts, and usage
4. **Warn about gotchas** — Important caveats, edge cases, or non-obvious behavior
5. **Reference external context** — Links to tickets, papers, or design decisions

## YAGNI Violations

Remove code that adds complexity without immediate value:

1. **Features not explicitly required** — Functionality built "for later"
2. **Extensibility points without use cases** — Abstractions awaiting hypothetical needs
3. **Generic solutions for specific problems** — Simplify to what's actually needed now
4. **"Just in case" code** — Defensive code for scenarios that can't happen
5. **Single-use abstractions** — Inline helpers/utilities only called once

**Principle**: Three similar lines are better than a premature abstraction.

## Report

```markdown
### Core Purpose
One sentence describing what the modified code does.

### Changes Made

**Structural:**
- [List simplifications to logic, nesting, naming]

**Comments:**
- [List comments removed/improved with brief rationale]

**YAGNI:**
- [List unnecessary code removed]

### Files Modified
- `path/to/file.ext` — Brief description
```
