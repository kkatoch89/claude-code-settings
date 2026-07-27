# Type Safety Reference

Proactive strategies for identifying and eliminating unsafe type patterns in TypeScript codebases.

## Core Mission

Actively search for and eliminate unsafe type patterns. TypeScript's type system is only as strong as the discipline applied to it. This reference provides strategies for hunting down type safety violations and replacing them with proper types.

## Unsafe Pattern Hunting

### Identifying `any` Usage

Search for and replace all instances of `any` with proper types:

```typescript
// Bad: explicit any
function processData(data: any): any {
  return data.map((item: any) => item.name);
}

// Good: proper types
function processData(data: User[]): string[] {
  return data.map((item) => item.name);
}
```

### Eliminating `as any` Assertions

Type assertions with `as any` bypass the type checker entirely. Find and remove them:

```typescript
// Bad: as any to silence errors
const result = someFunction() as any;
const value = (event.target as any).value;

// Good: proper narrowing or correct types
const result: ExpectedType = someFunction();
const target = event.target as HTMLInputElement;
const value = target.value;
```

### Removing Unnecessary Type Assertions

Type assertions (`as`) should be a last resort. Validate their necessity:

```typescript
// Bad: assertion when narrowing works
const user = data as User;

// Good: type guard
function isUser(data: unknown): data is User {
  return (
    typeof data === 'object' &&
    data !== null &&
    'id' in data &&
    'name' in data
  );
}

if (isUser(data)) {
  // data is now typed as User
  console.log(data.name);
}
```

### Finding Catch-All Patterns

Locate `*` types and overly broad generic parameters:

```typescript
// Bad: catch-all
type Handler = (event: any) => void;
type Config = Record<string, any>;

// Good: specific types
type Handler = (event: MouseEvent | KeyboardEvent) => void;
type Config = {
  apiUrl: string;
  timeout: number;
  retries: number;
};
```

## Advanced Type Patterns

### Generics for Reusable Type Safety

```typescript
// Generic function that preserves type information
function pick<T, K extends keyof T>(obj: T, keys: K[]): Pick<T, K> {
  const result = {} as Pick<T, K>;
  for (const key of keys) {
    result[key] = obj[key];
  }
  return result;
}

// Usage: types flow through
const nameAndEmail = pick(user, ['name', 'email']);
// Type: Pick<User, 'name' | 'email'>
```

### Conditional Types

```typescript
// Extract return type of async functions
type AsyncReturnType<T extends (...args: any[]) => Promise<any>> =
  T extends (...args: any[]) => Promise<infer R> ? R : never;

// Make types dependent on conditions
type ApiResponse<T> = T extends Array<infer U>
  ? { items: U[]; total: number }
  : { item: T };
```

### Mapped Types for Transformations

```typescript
// Make all properties optional and nullable
type Patchable<T> = {
  [K in keyof T]?: T[K] | null;
};

// Create readonly version
type Immutable<T> = {
  readonly [K in keyof T]: T[K] extends object ? Immutable<T[K]> : T[K];
};

// Extract only string properties
type StringKeys<T> = {
  [K in keyof T as T[K] extends string ? K : never]: T[K];
};
```

### Branded Types

Prevent mixing up primitive values that have different semantic meanings:

```typescript
type UserId = string & { readonly __brand: 'UserId' };
type OrderId = string & { readonly __brand: 'OrderId' };
type Email = string & { readonly __brand: 'Email' };

function createUserId(id: string): UserId {
  // Optionally validate
  return id as UserId;
}

function createEmail(email: string): Email {
  if (!email.includes('@')) throw new Error('Invalid email');
  return email as Email;
}

// Cannot accidentally swap
function getUser(id: UserId): User { /* ... */ }
function getOrder(id: OrderId): Order { /* ... */ }

getUser(orderId); // Type error
```

### Template Literal Types

```typescript
// Type-safe event names
type EventName = `on${Capitalize<'click' | 'focus' | 'blur'>}`;
// 'onClick' | 'onFocus' | 'onBlur'

// Type-safe CSS properties
type CSSUnit = 'px' | 'rem' | 'em' | '%';
type CSSValue = `${number}${CSSUnit}`;
```

### Type Guards and Assertion Functions

```typescript
// Type guard
function isString(value: unknown): value is string {
  return typeof value === 'string';
}

// Assertion function
function assertDefined<T>(
  value: T | null | undefined,
  message: string
): asserts value is T {
  if (value === null || value === undefined) {
    throw new Error(message);
  }
}

// Usage
assertDefined(user, 'User must be defined');
// user is now typed as User (not User | null | undefined)
```

## Compiler Configuration for Maximum Safety

```json
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "noPropertyAccessFromIndexSignature": true,
    "exactOptionalPropertyTypes": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "noImplicitOverride": true
  }
}
```

## Runtime Validation with Compile-Time Safety

Pair runtime validation with TypeScript types for data from external sources:

```typescript
// Using Zod for runtime validation
import { z } from 'zod';

const UserSchema = z.object({
  id: z.string(),
  name: z.string(),
  email: z.string().email(),
  role: z.enum(['admin', 'user', 'guest']),
});

type User = z.infer<typeof UserSchema>;

// Runtime-safe parsing
function parseUser(data: unknown): User {
  return UserSchema.parse(data);
}
```

## Audit Workflow

When tasked with improving type safety in a codebase:

1. Search for `any` type annotations
2. Search for `as any` assertions
3. Search for `@ts-ignore` and `@ts-expect-error` comments
4. Search for `!` non-null assertions
5. Search for broad `as` type assertions
6. Review each finding and replace with proper types
7. Run `tsc --noEmit` to verify no new errors

## Anti-Patterns to Prevent

- Using `any` as a permanent solution (use `unknown` and narrow)
- Silencing errors with `@ts-ignore` instead of fixing the type
- Overusing type assertions (`as`) instead of type guards
- Creating overly complex conditional types that hurt readability
- Fighting structural typing instead of embracing it
- Using `!` non-null assertion instead of proper null checks
- Casting to `any` as an intermediate step in type conversions

## What This Reference Does NOT Cover

- React-specific type patterns (see `react-architecture.md`)
- GraphQL type generation (see `graphql-integration.md`)
- General TypeScript patterns (see `typescript-core.md`)

## Goal

Help developers proactively identify and eliminate type safety violations, resulting in codebases where TypeScript's compiler catches the maximum number of bugs at compile time.
