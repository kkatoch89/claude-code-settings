---
description: Write code-level documentation (module headers, function docs, inline comments)
argument-hint: <file-path or module name>
---

# Code-Level Documentation

Write module headers, function/method docs, and inline comments for the specified code.

## Workflow

1. Read the target file(s)
2. For each module/function, determine: What does it do? Why does it exist? What's non-obvious?
3. Write module headers with: one-line summary, key behaviors, dependencies, usage example
4. Write function docs with: description, parameters, returns, side effects, errors
5. Add inline comments only for WHY, not WHAT
6. Apply LLM patterns: fully qualified names, no ambiguous pronouns, consistent section order
7. Validate against Ousterhout checklist: reduces cognitive load, interface not implementation, non-obvious things documented

## Rules

- Interface docs describe WHAT, not HOW
- Do not restate what the code already says
- Follow the language's doc convention (Elixir: @moduledoc/@doc, TypeScript: JSDoc, Python: docstrings)
- Code-level docs do NOT go through writing-for-humans post-processing
