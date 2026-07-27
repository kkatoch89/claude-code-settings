---
name: creating-skills
description: |
  Guidance for creating, auditing, and improving skills. Use when authoring
  new skills, improving existing SKILL.md files, or understanding skill
  structure and prompt design patterns.
---

# Creating Skills

A skill is a directory under `skills/` with a `SKILL.md` entry point. The frontmatter handles discovery; the body is the behavioral prompt. Add `references/`, `workflows/`, `commands/`, or `templates/` only when the core prompt needs progressive disclosure.

## Quick Start

Create `skills/my-skill/SKILL.md`:

```markdown
---
name: my-skill
description: "Generates weekly status reports from git logs. Use when asked for status updates or standup summaries."
---

# My Skill

## Quick Start
Run `git log --since="1 week ago"` and summarize changes by author.

## Instructions
1. Gather commits from the past week
2. Group by author and category (feature, fix, chore)
3. Summarize in bullet points
```

## Principles

1. **Description drives discovery** — The `description` field determines when a skill gets selected. Say what it does AND when to use it. Write in third person.

2. **One skill, one job** — If the prompt says "and also handles X," split it. Focused skills are easier to invoke, audit, and improve.

3. **SKILL.md is the contract** — The body defines identity, workflow, and output format. Keep runtime configuration out of canonical skill files.

4. **Keep it lean** — Skills are loaded in full when invoked. Move deep content into `references/` and reusable procedures into `workflows/`. Most skills are a single SKILL.md.

## Frontmatter

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Lowercase-with-hyphens, matches directory name (max 64 chars) |
| `description` | Yes | What it does AND when to use it (max 1024 chars) |
| `allowed-tools` | No | Tools the skill can use without asking |
| `model` | No | Specific model override |

**Naming**: Use gerund form — `reviewing-code`, `processing-pdfs`, `writing-documentation`. Avoid `helper`, `utils`, `tools`.

## Directory Layout

```
skills/my-skill/
├── SKILL.md          # Entry point (required)
├── references/       # Deep content, loaded on demand
├── workflows/        # Step-by-step procedures
├── commands/         # Slash command entry points
├── templates/        # Reusable output templates
└── scripts/          # Utility scripts (executed, not loaded)
```

Only create subdirectories when needed. Most skills are a single SKILL.md.

## Audit Checklist

### Frontmatter
- [ ] `name` lowercase-with-hyphens, matches directory
- [ ] `description` says what it does and when to use it

### Structure
- [ ] Quick Start or clear entry point
- [ ] Core instructions defined
- [ ] Output format specified (when applicable)
- [ ] Under 500 lines
- [ ] Deep content in `references/`, not inline

### Quality
- [ ] Single responsibility — one clear mission
- [ ] No placeholder text or TODOs
- [ ] No personal paths or environment assumptions
- [ ] Referenced files exist and links resolve

## References

- [Official Spec](references/official-spec.md) — Anthropic's skill specification
- [Best Practices](references/best-practices.md) — Authoring patterns and anti-patterns
- [Prompt Levels](references/prompt-levels.md) — Seven levels of prompt sophistication
- [Prompt Engineering Patterns](references/prompt-engineering-patterns.md) — Writing clear, effective prompts
