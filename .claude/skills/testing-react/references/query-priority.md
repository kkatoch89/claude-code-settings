# Query Priority Reference

Strategies for selecting the right React Testing Library query, with emphasis on accessible queries that reflect how users and assistive technology interact with components.

## The Priority Order

Always use the highest-priority query that works for your use case.

### Tier 1: Preferred Queries

These queries reflect how users and assistive technology interact with the page. They should be your default choice.

#### `getByRole` -- The Most Important Query

Queries the accessibility tree. This is the single most valuable query because it tests the component the way a screen reader sees it.

```typescript
// Buttons
screen.getByRole('button', { name: 'Submit Order' });
screen.getByRole('button', { name: /save/i });

// Headings
screen.getByRole('heading', { name: 'Dashboard' });
screen.getByRole('heading', { level: 2 });

// Form elements
screen.getByRole('textbox', { name: 'Email' });
screen.getByRole('checkbox', { name: 'Remember me' });
screen.getByRole('combobox', { name: 'Country' });
screen.getByRole('radio', { name: 'Monthly' });
screen.getByRole('spinbutton', { name: 'Quantity' });

// Navigation and structure
screen.getByRole('navigation');
screen.getByRole('dialog', { name: 'Confirm deletion' });
screen.getByRole('alert');
screen.getByRole('tab', { selected: true });
screen.getByRole('link', { name: 'View details' });

// Tables
screen.getByRole('table');
screen.getByRole('row', { name: /widget/i });
screen.getByRole('columnheader', { name: 'Price' });
```

The `name` option matches the element's **accessible name**, computed from:
- `aria-label` attribute
- `aria-labelledby` reference
- Visible text content
- Associated `<label>` element

#### `getByLabelText` -- Form Elements

The best query for form fields with associated labels.

```typescript
screen.getByLabelText('Email address');
screen.getByLabelText('Password');
screen.getByLabelText(/phone number/i);
```

#### `getByText` -- Non-Interactive Content

For paragraphs, spans, and other non-interactive elements identified by their text.

```typescript
screen.getByText('No results found');
screen.getByText(/total: \$\d+\.\d{2}/i);
screen.getByText('Welcome to the Dashboard');
```

#### `getByDisplayValue` -- Current Form Values

For form elements identified by their current value.

```typescript
screen.getByDisplayValue('alice@example.com');
```

#### `getByTestId` -- Via `data-testid` Attribute

Use alongside `getByRole` when the role query alone is insufficient, or for complex custom components (e.g., canvas-based charts) that have no accessible role.

```typescript
screen.getByTestId('revenue-chart');
screen.getByTestId('drag-handle');
```

### Tier 2: Backup Queries

Use these when the preferred queries cannot work.

#### `getByPlaceholderText` -- Inputs Without Labels

When a form field lacks a proper `<label>` (not ideal, but sometimes necessary).

```typescript
screen.getByPlaceholderText('Search products...');
```

### Tier 3: Rarely Needed

#### `getByAltText` -- Images

```typescript
screen.getByAltText('Company logo');
```

#### `getByTitle` -- Title Attributes

```typescript
screen.getByTitle('Close sidebar');
```

## What to Avoid

### Never Query By These

- **Array index or element order**: Fragile and breaks on any reorder
- **CSS selectors**: `container.querySelector('.btn-primary')` bypasses accessibility
- **Class names**: `getByClassName` does not exist in RTL for good reason
- **Implementation details**: Internal component state, hook values, or DOM structure

### Anti-Pattern Examples

```typescript
// Bad: CSS selector
container.querySelector('.submit-btn');
// Good:
screen.getByRole('button', { name: 'Submit' });

// Bad: test ID when a role query works
screen.getByTestId('submit-button');
// Good:
screen.getByRole('button', { name: 'Submit' });

// Bad: querying by class name
container.querySelector('[class*="active"]');
// Good:
screen.getByRole('tab', { selected: true });

// Bad: querying by index
screen.getAllByRole('listitem')[2];
// Good: use within() to scope
const list = screen.getByRole('list', { name: 'Products' });
within(list).getByText('Widget');
```

## Decision Flowchart

When choosing a query, follow this path:

1. **Is it a button, link, heading, form control, dialog, or navigation?** Use `getByRole`.
2. **Is it a form field with a label?** Use `getByLabelText`.
3. **Is it identified by its text content?** Use `getByText`.
4. **Is it an input with a current value?** Use `getByDisplayValue`.
5. **Does it only have a placeholder?** Use `getByPlaceholderText`.
6. **Is it an image?** Use `getByAltText`.
7. **Nothing else works?** Add a `data-testid` and use `getByTestId`.

Before using `getByTestId`, always ask: can I add an `aria-label`, a `<label>`, or use `getByRole` instead?

## Why This Order Matters

Accessible queries serve double duty:
1. They test that your component is accessible to assistive technology
2. They are resilient to refactoring -- as long as the user experience is preserved, the tests pass

Tests that query by CSS selectors, class names, or DOM structure break when you refactor styling or restructure HTML, even if the user experience is unchanged.

## Common Role References

| Element | Implicit Role |
|---------|--------------|
| `<button>` | `button` |
| `<a href>` | `link` |
| `<input type="text">` | `textbox` |
| `<input type="checkbox">` | `checkbox` |
| `<input type="radio">` | `radio` |
| `<select>` | `combobox` |
| `<h1>`-`<h6>` | `heading` |
| `<nav>` | `navigation` |
| `<header>` | `banner` |
| `<footer>` | `contentinfo` |
| `<main>` | `main` |
| `<dialog>` | `dialog` |
| `<table>` | `table` |
| `<tr>` | `row` |
| `<th>` | `columnheader` |
| `<ul>`, `<ol>` | `list` |
| `<li>` | `listitem` |
| `<img>` | `img` |

## Goal

Help developers select queries that validate accessibility, survive refactoring, and reflect how real users interact with components.
