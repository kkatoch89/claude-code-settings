---
description: Write architecture documentation (ADRs, design docs, system overviews)
argument-hint: <system or decision to document>
---

# Architecture Documentation

Write system overviews, ADRs, design docs, or module interaction descriptions.

## Workflow

1. Gather context: read project structure, identify modules, trace data flow
2. Detect doc type: ADR | Design Doc | System Overview | Module Interactions
3. Follow the appropriate template structure
4. Apply dual-audience principles (Ousterhout + LLM patterns)
5. Validate: stands alone, fully qualified names, cross-module interactions explicit, WHY documented

## ADR Rules

- One decision per ADR, numbered sequentially
- Title is the decision ("Use PostgreSQL for persistence"), not the problem
- Context section must stand alone for unfamiliar readers

## Architecture docs do NOT go through writing-for-humans post-processing.
