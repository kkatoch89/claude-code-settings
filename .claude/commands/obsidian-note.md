---
argument-hint: <topic name to capture>
description: Create a structured learning note in the Obsidian slip-box folder
---

You are creating a structured learning note in the user's Obsidian slip-box for a topic that came up during the current conversation. The goal is a distilled, reusable note the user can find again months later via Obsidian search.

## Scope — what this command IS for

Use this command to capture **topics worth understanding deeply enough to re-apply elsewhere**:

- Concepts / principles (e.g. ACID, denormalization, optimistic concurrency)
- Patterns / antipatterns (e.g. n+1, fan-out, circuit breaker)
- Comparisons (e.g. TCP vs UDP, REST vs GraphQL)
- Library / framework behaviors (e.g. dataloader, useImperativeHandle)
- Mechanisms / runtime behaviors (e.g. event loop, browser paint)
- Algorithms / techniques (e.g. genetic algorithms, password salting)
- Technologies (e.g. containers, mongodb)
- Architectural designs (e.g. auditor events table, CQRS)

## What this command is NOT for

If the topic is one of these, tell the user this command isn't the right fit and suggest they write the note freehand instead:

- Pure CLI / API cheatsheets (no real "concept" to distill)
- One-off error / debug fixes (specific symptom → specific cause → specific fix)
- Codebase-specific component reference
- Internal tooling docs
- Non-technical reading notes

The structure this command enforces (essence / concept / trade-offs / use cases) doesn't fit those, and forcing it produces awkward notes.

## Vault location

Always write to: `/Users/karankatoch/Vaults/Karan's notes/slip-box/<Title>.md`

Never write outside `slip-box/`. If a note with the chosen title already exists, ask whether to append, replace, or pick a different title — never silently overwrite.

## Determining the topic

The argument `$ARGUMENTS` is the topic. If empty or vague, infer it from the most recent technical discussion in this conversation and confirm with the user before writing.

## Title rules — discoverability is the priority

The filename IS the title. It must name the topic explicitly so future-you can find it via Obsidian search. Match the user's existing slip-box naming conventions:

- Sentence case with spaces (NOT kebab-case, NOT snake_case, NOT TitleCase)
- Names the topic directly, no clever phrasing
- For comparisons: `X vs Y in <domain>` — e.g. `Denormalization vs Normalization in databases`
- For language-specific: append the language — e.g. `Closures in JavaScript`, `Pattern matching in Elixir`
- For libraries / tools: just the name — e.g. `dataloader`, `XState`, `Apollo caching`

Good titles:
- `Denormalization vs Normalization in databases`
- `Optimistic concurrency control`
- `Circuit breaker pattern`
- `useEffect cleanup functions`

Bad titles (too vague, undiscoverable):
- `Database stuff`
- `What I learned today`
- `Some patterns`

## Template format — match exactly

```
YYYY-MM-DD HH:MM

Status: #adult

Tags: [[tag1]] [[tag2]]

# {{Title}}

[content]

# References

[references]
```

Rules:
- Get the actual current timestamp by running `date "+%Y-%m-%d %H:%M"`
- Status is always `#adult` (slip-box notes are polished/permanent)
- Tags use **wikilinks** (`[[db]]`), NOT hashtags. Common tags in this vault: `[[db]]`, `[[programming]]`, `[[react]]`, `[[js]]`, `[[elixir]]`, `[[css]]`, `[[networking]]`, `[[linux]]`. Pick 1-3 that fit.
- Title at H1, References at H1 at the bottom
- Body uses H2 (`##`) for major sections

## Content structure — in this order

1. **Essence (1-2 sentences)** — define the topic in plain language. Lead with what it IS before how it works. A blockquote often works well here.

2. **General concept** — explain how it works, what problem it solves, the underlying principle. Bullet points liberally; tables for comparisons; small code blocks or ASCII diagrams when they clarify.

3. **Pros / cons (or trade-offs)** — what does this approach optimize for? What does it cost? Use a table when there are multiple dimensions.

4. **Use cases** — concrete situations where you'd reach for this, paired with situations where you'd NOT. When applicable: "Use when ALL of X, Y, Z are true; avoid when..."

5. **Where it generalizes (optional)** — if the topic transcends its origin (e.g., a SQL pattern that also applies to NoSQL / caches / CQRS), include this. Skip if the topic is genuinely local to one domain.

6. **The situation it came up in (closing paragraph)** — 2-4 sentences describing the conversation / codebase context that prompted this note. Mention specific files, tickets, or scenarios. This grounds the abstract topic in real work and helps future-you remember why you wrote it down.

## Style guidance — match existing slip-box notes

- Bullet-heavy and compact. Reference examples: `Indexes in postgres.md`, `Relational vs Document DBs.md`, `Long-polling vs WebSockets vs Server-Sent Events (SSE).md`.
- Tables for trade-off comparisons.
- Fenced code blocks for syntax / SQL / examples.
- ASCII diagrams sparingly when they help visualize relationships.
- Wikilinks (`[[Note Name]]`) for related concepts. List `/Users/karankatoch/Vaults/Karan's notes/slip-box/` first so you only link to notes that actually exist.
- Slip-box notes distill — they don't exhaustively reference. Cut anything that doesn't earn its place.

## Process

1. Determine the topic from `$ARGUMENTS` (or infer from conversation + confirm).
2. Verify the topic fits this command's scope. If not (cheatsheet / error / codebase-specific / non-technical), tell the user and stop.
3. **Check for an existing note on this topic** by invoking the `lookup-obsidian` skill with the topic. If it returns matches:
   - Show them to the user.
   - Ask how to proceed: **append** to the existing note, **replace** it, **skip** (the existing note already covers it), or **pick a new title** because this is genuinely a distinct concept.
   - Only proceed past this step once the user picks an option. Never silently overwrite or auto-edit an existing slip-box note.
4. Pick a discoverable title following the rules above.
5. Run `date "+%Y-%m-%d %H:%M"` to get the timestamp.
6. List `/Users/karankatoch/Vaults/Karan's notes/slip-box/` to find existing notes worth wikilinking.
7. Check for filename collision; if a note with the same title exists, confirm with the user.
8. Write the note following the template + content structure.
9. Report the path back to the user.

## Important constraints

- Do NOT read the contents of unrelated notes in the vault — only list filenames to find wikilink candidates.
- Do NOT modify other notes in the vault.
- Do NOT include sensitive content from work conversations. Internal codebase paths and ticket IDs are fine in a personal vault; specific user data, customer names, or PHI are not.

Now create the note for: $ARGUMENTS
