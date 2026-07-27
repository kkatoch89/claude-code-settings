---
name: lookup-obsidian
description: Search the user's Obsidian slip-box for notes related to a given concept and return matches without modifying anything. Use when the user asks "do I already have a note on X?", before creating a new slip-box note to avoid duplicates, or whenever they want to find a note but aren't sure of the exact title.
---

Find existing slip-box notes related to a concept the user provides. Return matches; never edit, create, or delete notes.

## Vault location

Search only: `/Users/karankatoch/Vaults/Karan's notes/slip-box/`

Do not search other folders in the vault. Do not modify any files.

## Input

The concept to look up. If the user's input is vague, infer it from recent conversation context and confirm before searching.

## Process

1. **List filenames** in `slip-box/`. Filenames are the titles — that's the primary signal.

2. **Semantic match against filenames.** Don't require literal substring matches. Consider:
   - Synonyms and alternate phrasings (e.g. "optimistic locking" ↔ "optimistic concurrency control")
   - Parent / child concepts (e.g. "ACID" relates to "Transactions", "Isolation levels")
   - Comparison notes that include the concept on one side (e.g. a query for "GraphQL" should surface "REST vs GraphQL")
   - Language-specific variants (e.g. "closures" → "Closures in JavaScript")

3. **Pick top candidates.** Aim for at most 5. If filenames make the relevance obvious, you're done — skip step 4.

4. **Peek into ambiguous candidates only.** If a filename is close-but-not-obvious (e.g. query is "dataloader" and a candidate is "Solving n+1 in GraphQL"), read just enough of that file to decide if it actually covers the concept. Cap peeks at 3 files and read only the first ~40 lines of each. Do not read unrelated notes.

5. **Return matches** in this format:

   ```
   Found N possible match(es):

   1. <Filename> — <one-line summary of what it covers>
      Path: /Users/karankatoch/Vaults/Karan's notes/slip-box/<Filename>.md
      Relevance: <exact title | close synonym | parent concept | mentions in passing>

   2. ...
   ```

   If nothing matches, say so plainly: `No existing slip-box note found for "<concept>".`

6. **Stop there.** Don't suggest next steps unless asked — the caller (user or another command) decides what to do with the matches.

## Constraints

- Read-only. Never write, edit, or delete notes.
- Don't read more than 3 files, and only the first ~40 lines of each.
- Don't list or summarize the entire vault — only what's relevant to the query.
- Don't include note contents in the output beyond the one-line summary. The user can open the file if they want details.
