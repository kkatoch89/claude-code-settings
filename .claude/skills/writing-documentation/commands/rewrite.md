# Command: Rewrite

Perform a full rewrite of a document for clarity, conciseness, and scannability.

## Usage

`/writing-documentation rewrite` or `/writing-documentation rewrite [file path or pasted text]`

## When to Use

- A document needs both structural and word-level improvement
- Text reads as verbose, AI-generated, or hard to scan
- Producing final user-facing documentation from a draft

## Process

Follow the full rewriting workflow from SKILL.md:

1. **Diagnose** -- Scan using the diagnostic checklist. Identify top 3 issues.
2. **Structural rewrite** -- Apply BLUF, flatten nesting, fix headings, break long lists.
3. **Sentence-level rewrite** -- Delete filler, activate voice, replace weak verbs, split long sentences.
4. **Formatting** -- Apply visual hierarchy with markdown, headings, whitespace, tables.
5. **Validate** -- Check against success criteria (30-50% reduction, skim test, zero banned words).

## Input

Accept any of:
- A file path to read and rewrite
- Pasted text to rewrite
- A document produced by another skill as a post-processing step

## Output

Return **only** the rewritten text. Do not include:
- Explanations of what you changed
- Before/after comparisons
- Meta-commentary about the rewrite process
- Confidence scores or caveats

If the original text is already concise and scannable, return it unchanged with no comment.

## Success Criteria

- **30-50% word reduction** from the original
- **Passes skim test** -- headings and bold text convey the full message
- **Zero banned words** -- no filler phrases or vocabulary tics
- **80%+ active voice** -- measured by sentence count
- **Flesch-Kincaid grade 8-10** -- accessible to a broad technical audience
- **Every claim is concrete** -- numbers, names, or examples instead of adjectives

## References

- [llm-anti-patterns.md](../references/llm-anti-patterns.md) -- Diagnosing why text reads like AI output
- [conciseness-techniques.md](../references/conciseness-techniques.md) -- Editing for maximum word count reduction
