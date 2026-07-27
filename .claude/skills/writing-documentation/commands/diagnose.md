# Command: Diagnose

Analyze text for readability issues without rewriting. Produces a diagnostic report identifying what needs fixing and how severe each issue is.

## Usage

`/writing-documentation diagnose` or `/writing-documentation diagnose [file path or pasted text]`

## When to Use

- Quick assessment of a document's readability
- Deciding whether a full rewrite is needed
- Identifying the most impactful improvements before editing
- Reviewing documentation quality

## Process

1. **Scan the text** using the diagnostic checklist from SKILL.md
2. **Count issues** in each category (vocabulary, structure, readability)
3. **Rank by severity** -- which issues have the most impact on readability
4. **Report findings** with specific examples from the text

## Output Format

```markdown
## Diagnostic Report: [Document Name]

**Word count:** [N]
**Estimated reading level:** [grade N]

### Top Issues (fix these first)

1. **[Issue type]** -- [count] instances found
   Example: "[quoted text from document]"
   Fix: [specific recommendation]

2. **[Issue type]** -- [count] instances found
   Example: "[quoted text from document]"
   Fix: [specific recommendation]

3. **[Issue type]** -- [count] instances found
   Example: "[quoted text from document]"
   Fix: [specific recommendation]

### Checklist Results

**Vocabulary**
- [x/--] Banned words: [count] found ([list words])
- [x/--] Hedging language: [count] instances
- [x/--] Buzzwords: [count] instances
- [x/--] Intensifiers: [count] instances

**Structure**
- [x/--] Context before answer: [count] sections
- [x/--] Long paragraphs (>4 sentences): [count]
- [x/--] Long lists (>9 items unsplit): [count]
- [x/--] Deep nesting (>2 levels): [count]
- [x/--] Generic headings: [count]

**Readability**
- [x/--] Long sentences (>25 words): [count]
- [x/--] Passive voice: [estimated %]
- [x/--] Nominalizations: [count]
- [x/--] Abstract claims: [count]

### Recommendation

[One of: "Full rewrite recommended", "Targeted edits sufficient", "Document is clean"]

Estimated reduction potential: [N-M]%
```

## What This Does NOT Do

- Does not rewrite the text (use the `rewrite` command for that)
- Does not make changes to the document
- Does not produce a revised version

The diagnosis is purely analytical -- it identifies problems and recommends fixes without applying them.

## References

- [llm-anti-patterns.md](../references/llm-anti-patterns.md) -- Detection patterns for AI-generated text
- [conciseness-techniques.md](../references/conciseness-techniques.md) -- Readability metrics and targets
