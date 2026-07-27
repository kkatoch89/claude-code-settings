---
name: developing-typescript
description: |
  Comprehensive TypeScript/React development expertise covering advanced type systems, React component architecture, hooks patterns, state management, GraphQL integration with Apollo, performance optimization, type safety enforcement, and code quality pipelines.

  Use when working with .ts/.tsx files, React components, or when the user mentions TypeScript, React, hooks, Context, Apollo, GraphQL codegen, React Testing Library, Vite, or Next.js. Also use for generic types, component patterns, bundle optimization, type safety audits, or code quality checks.
---

# Developing TypeScript

Expert guidance for building robust, type-safe TypeScript and React applications.

## Quick Start

For immediate help, identify your task type and consult the relevant reference:

| Working On | Reference File | Key Topics |
|------------|----------------|------------|
| Generics, conditional types, inference | [typescript-core](references/typescript-core.md) | Type system, utility types, declarations |
| Components, hooks, state management | [react-architecture](references/react-architecture.md) | Composition, Context, reducers, BulletProof React |
| React 19, Server Components, Actions | [react-19-patterns](references/react-19-patterns.md) | ref as prop, useActionState, use(), Server Actions |
| Apollo Client, codegen, type safety | [graphql-integration](references/graphql-integration.md) | Queries, mutations, cache |
| Apollo cache, subscriptions, optimistic UI | [apollo-patterns](references/apollo-patterns.md) | Cache management, subscriptions, batching |
| Bundle size, memoization, Core Web Vitals | [performance](references/performance.md) | Code splitting, profiling |
| Eliminating any, branded types, generics | [type-safety](references/type-safety.md) | Proactive unsafe pattern hunting |
| ESLint, Prettier, type checking pipeline | [quality-pipeline](references/quality-pipeline.md) | yarn eslint, format, types:check |

## TDD Phase Awareness

All guidance in this skill is phase-aware. Identify your current phase:

### RED Phase (Writing Failing Tests)
- Write the smallest test that captures intent
- Use concrete values directly in tests
- Focus on user behavior, not implementation
- Skip edge cases and complex mocking initially

### GREEN Phase (Making Tests Pass)
- RESIST over-engineering at all costs
- Start with simple implementations
- Use `any` temporarily if types block progress
- Focus only on making the current test pass

### REFACTOR Phase (Improving Design)
- NOW apply proper type constraints
- Extract custom hooks from components
- Add comprehensive type definitions
- Improve component composition patterns

## Cross-Cutting Principles

These principles apply across all TypeScript/React development:

### Type Safety First
1. Prefer compile-time errors over runtime errors
2. Use strict mode and appropriate compiler options
3. Leverage type inference where it improves readability
4. Create discriminated unions for state management

### Component Architecture
1. Prefer composition over prop drilling
2. Keep components focused on single responsibilities
3. Use custom hooks to extract reusable logic
4. Push side effects to dedicated hooks or boundaries

### Testing Philosophy
- Test user behavior, not implementation details
- Write tests that can fail for real defects
- Avoid over-mocking; prefer integration tests
- Use React Testing Library queries by accessibility

### Performance Mindset
- Measure before optimizing
- Understand React's rendering model
- Use memoization strategically, not reflexively
- Consider bundle size for every dependency

## Examples

**Creating a type-safe form component:**
```
User: "I need a reusable form that handles different data types"
-> Consult typescript-core.md for generics, react-architecture.md for patterns
```

**Optimizing re-renders:**
```
User: "My component re-renders too often"
-> Consult performance.md for profiling and memoization strategies
```

**Setting up GraphQL with type safety:**
```
User: "Integrate Apollo Client with TypeScript codegen"
-> Consult graphql-integration.md for setup and apollo-patterns.md for advanced cache management
```

**Writing component tests:**
```
User: "Test this form submission flow"
-> Consult the testing-react skill for user behavior testing patterns
```

**Hunting unsafe types:**
```
User: "Clean up all the any types in this module"
-> Consult type-safety.md for proactive unsafe pattern hunting strategies
```

**Running the quality pipeline:**
```
User: "Check this code for style and type issues"
-> Consult quality-pipeline.md for the lint -> format -> type-check workflow
```

## Anti-Patterns to Avoid

### Premature Abstraction
- Creating generic components before you have 3 similar cases
- Building complex type utilities for one-off uses
- Over-engineering state management with Context
- Adding dependency injection patterns unnecessarily

### Type System Misuse
- Using `any` to silence errors instead of fixing types
- Over-constraining types that limit legitimate use cases
- Creating deep type hierarchies that confuse inference
- Ignoring TypeScript's structural typing strengths

### Testing Anti-Patterns
- Testing implementation details
- Over-mocking to the point tests don't catch real bugs
- Testing React internals instead of user outcomes
- Creating elaborate test utilities prematurely

### Performance Anti-Patterns
- Premature memoization without measurement
- useCallback/useMemo on every function/value
- Splitting code before you have bundle size problems
- Optimizing renders that aren't causing issues

## Reference File IDs

For programmatic access (e.g., parallel reviews), use these identifiers:

`typescript-core` . `react-architecture` . `react-19-patterns` . `graphql-integration` . `apollo-patterns` . `performance` . `type-safety` . `quality-pipeline`
