# Writing for Humans

Post-processing methodology for transforming dense documentation into scannable, concise, human-readable text.

## Core Principles

1. **79% scan, 21% read** — Front-load key information. Use headings, bold, and lists as scan anchors.
2. **7 plus/minus 2 chunks** — Group related items into 5-9 chunks. Split longer lists.
3. **BLUF (Bottom Line Up Front)** — Lead with the conclusion or action. Context follows.
4. **Active voice** — "The server processes requests" not "Requests are processed by the server."
5. **Show, don't tell** — Replace claims with evidence. "Reduces build time by 40%" not "Significantly improves performance."
6. **Concrete over abstract** — Use specific numbers, names, and examples.

## Rewriting Workflow

### Phase 1: Diagnosis
Scan for vocabulary tics (banned words), structural problems (context before answer, long paragraphs), and readability issues (passive voice, long sentences).

### Phase 2: Structural Rewrite
1. Apply BLUF — move conclusions to first sentence of each section
2. Front-load paragraphs — first sentence carries the point
3. Break long lists — split 7+ item lists into categorized sub-lists
4. Flatten nesting — 2 levels maximum
5. Replace generic headings — "Overview" becomes "What this does"

### Phase 3: Sentence-Level Rewrite
1. Delete filler — remove words that add no meaning
2. Activate voice — convert passive to active
3. Replace weak verbs — "utilize" becomes "use"
4. Reverse nominalizations — "make a determination" becomes "decide"
5. Split long sentences — break at 25+ words
6. Cut hedging — remove "basically", "essentially", "it's worth noting that"

### Phase 4: Formatting
1. Bold for key terms on first use, code formatting for technical names
2. One heading per ~300 words, specific and actionable
3. Short paragraphs (2-4 sentences)
4. Prefer tables for comparisons

### Phase 5: Validation
- 30-50% shorter than original
- Passes skim test (headings + bold text convey the gist)
- No banned words remain
- 80%+ active voice
- No paragraph exceeds 4 sentences

## Banned Words

delve, leverage, robust, comprehensive, streamline, utilize, facilitate, moreover, furthermore, nonetheless, paradigm, synergy, optimize (unless actual perf work), empower, foster, holistic, innovative, seamless

## Banned Phrases

"It's important to note that", "In order to", "At the end of the day", "It goes without saying", "Due to the fact that", "In the event that", "Prior to", "A wide range of", "Has the ability to"

## Word Replacements

| Replace | With |
|---------|------|
| utilize | use |
| facilitate | help |
| implement | build, add |
| functionality | feature |
| in order to | to |
| due to the fact that | because |
| a large number of | many |
| in the event that | if |
| has the ability to | can |
