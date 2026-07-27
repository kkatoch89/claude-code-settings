# Deciding How Many Acceptance Criteria

The right count depends on the story. These heuristics help:

| Signal | Action |
|--------|--------|
| Criteria have similar priority and story fits a sprint | Add criteria to the story |
| Criteria have different priorities | Split the story |
| Story feels too large for one sprint | Split the story (use SPIDR) |
| Areas where misunderstanding is likely | Add concrete examples |
| Areas where the team already agrees | Skip formal criteria -- conversation suffices |
| Each criterion needs at least one test | Minimum one acceptance test per criterion |

## Key Principles

**Keep stories small.** Focus on a small unit of behavior. At minimum, one
acceptance test per criterion -- usually more.

**Acceptance criteria include only things so important the product owner
would reject the story if unmet.** They are a "table of contents into a
test plan," not the test plan itself.

**Focus examples on areas of potential misunderstanding.** Not everything
needs formal criteria. Specificity matters more than coverage -- concrete
examples with named characters and real values reveal edge cases that
abstractions hide.

## SPIDR Splitting Technique

When a story needs splitting, use SPIDR:

- **Spike** -- Separate unknowns into research spikes
- **Path** -- Split by workflow path (happy path, error path, edge cases)
- **Interfaces** -- Split by platform, device, or integration point
- **Data** -- Split by data type or category
- **Rules** -- Split by business rule complexity

## Sources

- Farley, D. *Modern Software Engineering* (2021)
- Cohn, M. *User Stories Applied* (2004)
- Shore, J. *The Art of Agile Development* (2007, 2nd ed. 2021)
