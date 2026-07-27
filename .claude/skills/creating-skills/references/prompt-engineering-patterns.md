# Prompt Engineering Patterns

Patterns for writing clear, effective prompts that Claude executes reliably. These apply to both skills and agent prompts.

## Be Clear and Direct

Show your prompt to someone with minimal context and ask them to follow the instructions. If they're confused, Claude will likely be too.

### Give Contextual Information

Frame the task with context Claude needs:
- What the task results will be used for
- What audience the output is meant for
- What workflow the task is part of
- What successful completion looks like

### Be Specific

**Vague**: "Help with the report"
**Specific**: "Generate a markdown report with three sections: Executive Summary, Key Findings, Recommendations"

**Vague**: "Process the data"
**Specific**: "Extract customer names and email addresses from the CSV file, removing duplicates, and save to JSON format"

### Use Sequential Steps

Provide instructions as numbered steps. Sequential steps create clear expectations and reduce the chance Claude skips important operations.

```markdown
## Workflow
1. Extract data from source file
2. Transform to target format
3. Validate transformation
4. Save to output file
5. Verify output correctness
```

## Show, Don't Just Tell

When format matters, show an example rather than just describing it. Examples communicate nuances that text descriptions can't: exact formatting, tone, level of detail, and patterns across cases.

Claude learns patterns from examples more reliably than from descriptions.

## Avoid Ambiguity

Eliminate words and phrases that create ambiguity:

- "Try to..." (implies optional) -> "Always..." or "Never..."
- "Should probably..." (unclear obligation) -> "Must..." or "May optionally..."
- "Generally..." (when are exceptions allowed?) -> "Always... except when..."
- "Consider..." (always or sometimes?) -> "If X, then Y" or "Always..."

## Define Edge Cases

Anticipate edge cases and define how to handle them:

```markdown
## Edge Cases
- **No results found**: Return empty array `[]`
- **Duplicate entries**: Keep only unique items
- **Malformed input**: Skip invalid items, log to stderr
```

## Specify Output Format

When output format matters, show the exact template:

```markdown
## Output Format

Generate a markdown report with this exact structure:

# Analysis Report: [Title]

## Executive Summary
[1-2 paragraphs summarizing key findings]

## Key Findings
- Finding 1 with supporting data
- Finding 2 with supporting data

## Recommendations
1. Specific actionable recommendation
2. Specific actionable recommendation
```

## Provide Decision Criteria

When Claude must make decisions, provide clear criteria:

```markdown
**Use bar chart when**:
- Comparing quantities across categories
- Fewer than 10 categories

**Use line chart when**:
- Showing trends over time
- Continuous data
```

## Separate Requirements Clearly

Clearly distinguish "must do" from "nice to have" from "must not do":

```markdown
## Must Have
- Financial data (revenue, costs, profit margins)
- Maximum 5 pages

## Nice to Have
- Charts and visualizations
- Industry benchmarks

## Must Not
- Include confidential customer names
- Exceed 5 pages
```

## Define Success Criteria

Define what success looks like so Claude knows when it has succeeded:

```markdown
## Success Criteria
- All rows in CSV successfully parsed
- No data validation errors
- Report generated with all required sections
- Output file is valid markdown
```

## Use Consistent Terminology

Choose one term and use it throughout. Inconsistent terminology confuses Claude:

- **Good**: Always "API endpoint" (not mixing with "URL", "API route", "path")
- **Good**: Always "field" (not mixing with "box", "element", "control")
- **Good**: Always "extract" (not mixing with "pull", "get", "retrieve")

## Provide Default with Escape Hatch

Recommend ONE default approach with ONE escape hatch for edge cases. Too many options cause decision paralysis:

**Good**: "Use pdfplumber for text extraction. For scanned PDFs requiring OCR, use pdf2image with pytesseract instead."

**Bad**: "You can use pypdf, or pdfplumber, or PyMuPDF, or pdf2image, or pdfminer..."

## Constraint Patterns

### Place Constraints Near the Top

Constraints placed near the beginning of a prompt get more attention from the model. Don't bury important rules at the bottom.

### Use Strong Language for Constraints

- `DO NOT` for absolute prohibitions
- `ONLY` to reinforce boundaries
- `ALWAYS` for mandatory behaviors
- `NEVER` for forbidden actions

### Keep Constraint Count Reasonable

4-7 constraints is the sweet spot. More than that and they start getting ignored.
