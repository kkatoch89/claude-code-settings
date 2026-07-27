# Quality Pipeline Reference

Sequential code quality workflow for TypeScript projects: linting, formatting, and type checking.

## Pipeline Overview

Run these steps in order. Each step must pass before moving to the next.

```
yarn eslint --quiet  ->  yarn format:changed  ->  yarn types:check
```

### Step 1: Linting

```bash
yarn eslint --quiet
```

The `--quiet` flag suppresses warnings and shows only errors. Fix all errors before proceeding.

Common ESLint fixes:
- Unused imports and variables
- Missing return types on exported functions
- Incorrect hook dependency arrays
- Forbidden patterns (e.g., `console.log` in production code)

### Step 2: Formatting

```bash
yarn format:changed
```

This formats only files that have been modified, keeping diffs clean. If your project uses a different command, common alternatives include:

- `yarn prettier --write .` (format everything)
- `npx prettier --write --changed` (format changed files)

Fix any formatting issues the tool surfaces. Formatting should be consistent with project Prettier configuration.

### Step 3: Type Checking

```bash
yarn types:check
```

This runs the TypeScript compiler without emitting files (`tsc --noEmit`). Fix all type errors before the pipeline is complete.

Common type errors to address:
- Missing type annotations
- Incompatible types in assignments
- Missing properties on objects
- Incorrect generic type parameters
- Null/undefined access without checks

## Pipeline Rules

1. **Sequential execution**: Each step must pass before moving to the next
2. **No backtracking**: Once a step passes, do not return to it until the pipeline is run again
3. **Fix at the source**: When a type error is found, fix the type -- do not add `as any` or `@ts-ignore`
4. **Track violations**: Keep track of issues found and fixed

## Integration with Development Workflow

### Pre-commit Hook

The pipeline integrates well with pre-commit hooks via tools like `lint-staged`:

```json
{
  "lint-staged": {
    "*.{ts,tsx}": [
      "eslint --quiet --fix",
      "prettier --write"
    ]
  }
}
```

### CI Pipeline

In CI, run the full pipeline as a check:

```bash
yarn eslint --quiet && yarn format:check && yarn types:check
```

Note: In CI, use `format:check` (not `format:changed`) to verify formatting without modifying files.

## Naming and Style Conventions

These conventions should be enforced by ESLint rules and verified during the linting step:

- PascalCase for components and types
- camelCase for variables, functions, and hooks
- UPPER_SNAKE_CASE for constants
- Consistent file naming matching the project convention
- Prefer direct imports over barrel exports for better tree-shaking
- Modern JavaScript/TypeScript syntax (optional chaining, nullish coalescing)

## What This Reference Does NOT Cover

- Specific ESLint rule configuration
- Prettier configuration options
- Test execution (see the testing-react skill)

## Goal

Provide a repeatable, ordered workflow for ensuring code quality across linting, formatting, and type safety in TypeScript projects.
