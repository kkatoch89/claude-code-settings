# Interaction Testing

Testing user interactions with userEvent and form submissions.

## userEvent Setup

Always use `userEvent.setup()` at the start of tests. This creates a user instance that properly simulates real browser behavior.

```tsx
import userEvent from '@testing-library/user-event'

it('handles button click', async () => {
  const user = userEvent.setup()
  const handleClick = jest.fn()

  render(<Button onClick={handleClick}>Submit</Button>)

  await user.click(screen.getByRole('button', { name: 'Submit' }))

  expect(handleClick).toHaveBeenCalledTimes(1)
})
```

### userEvent vs fireEvent

**Prefer userEvent.** It simulates complete user interactions including focus, blur, keyboard events, and pointer events in the correct order.

```tsx
// Good: simulates real typing (focus, keydown, keypress, input, keyup for each char)
await user.type(screen.getByRole('textbox', { name: 'Email' }), 'alice@example.com')

// Avoid: dispatches raw DOM event only
fireEvent.change(screen.getByRole('textbox', { name: 'Email' }), {
  target: { value: 'alice@example.com' },
})
```

Use `fireEvent` only when `userEvent` cannot simulate a specific browser event (rare).

## Click Interactions

```tsx
// Single click
await user.click(screen.getByRole('button', { name: 'Add to Cart' }))

// Double click
await user.dblClick(screen.getByRole('row', { name: /order #123/i }))

// Right click
await user.pointer({ keys: '[MouseRight]', target: screen.getByText('Item') })
```

## Typing

```tsx
// Type into an input
await user.type(screen.getByRole('textbox', { name: 'Email' }), 'alice@example.com')

// Clear and type
await user.clear(screen.getByRole('textbox', { name: 'Email' }))
await user.type(screen.getByRole('textbox', { name: 'Email' }), 'bob@example.com')

// Type special keys
await user.type(screen.getByRole('textbox'), '{Enter}')
await user.type(screen.getByRole('textbox'), '{Escape}')
await user.type(screen.getByRole('textbox'), '{Backspace}')

// Keyboard shortcuts
await user.keyboard('{Control>}a{/Control}')  // Ctrl+A (select all)
```

## Form Submission

```tsx
describe('OrderForm', () => {
  it('submits form with valid data', async () => {
    const user = userEvent.setup()
    const handleSubmit = jest.fn()

    render(<OrderForm onSubmit={handleSubmit} />)

    await user.type(
      screen.getByRole('textbox', { name: 'Product Name' }),
      'Widget'
    )
    await user.type(
      screen.getByRole('spinbutton', { name: 'Quantity' }),
      '5'
    )
    await user.selectOptions(
      screen.getByRole('combobox', { name: 'Shipping' }),
      'express'
    )
    await user.click(screen.getByRole('button', { name: 'Place Order' }))

    expect(handleSubmit).toHaveBeenCalledWith({
      productName: 'Widget',
      quantity: 5,
      shipping: 'express',
    })
  })

  it('shows validation errors for empty required fields', async () => {
    const user = userEvent.setup()

    render(<OrderForm onSubmit={jest.fn()} />)

    await user.click(screen.getByRole('button', { name: 'Place Order' }))

    expect(screen.getByText('Product name is required')).toBeInTheDocument()
    expect(screen.getByText('Quantity must be at least 1')).toBeInTheDocument()
  })

  it('disables submit button while submitting', async () => {
    const user = userEvent.setup()

    render(<OrderForm onSubmit={() => new Promise(() => {})} />)

    await user.type(
      screen.getByRole('textbox', { name: 'Product Name' }),
      'Widget'
    )
    await user.click(screen.getByRole('button', { name: 'Place Order' }))

    expect(screen.getByRole('button', { name: /submitting/i })).toBeDisabled()
  })
})
```

## Select and Option Interactions

```tsx
// Select by visible text
await user.selectOptions(
  screen.getByRole('combobox', { name: 'Country' }),
  'United States'
)

// Select by value
await user.selectOptions(
  screen.getByRole('combobox', { name: 'Country' }),
  'US'
)

// Multi-select
await user.selectOptions(
  screen.getByRole('listbox', { name: 'Tags' }),
  ['urgent', 'important']
)

// Deselect in multi-select
await user.deselectOptions(
  screen.getByRole('listbox', { name: 'Tags' }),
  'important'
)
```

## Checkbox and Radio

```tsx
// Toggle checkbox
await user.click(screen.getByRole('checkbox', { name: 'Accept terms' }))
expect(screen.getByRole('checkbox', { name: 'Accept terms' })).toBeChecked()

// Uncheck
await user.click(screen.getByRole('checkbox', { name: 'Accept terms' }))
expect(screen.getByRole('checkbox', { name: 'Accept terms' })).not.toBeChecked()

// Radio buttons
await user.click(screen.getByRole('radio', { name: 'Express shipping' }))
expect(screen.getByRole('radio', { name: 'Express shipping' })).toBeChecked()
expect(screen.getByRole('radio', { name: 'Standard shipping' })).not.toBeChecked()
```

## Tab Navigation

```tsx
it('supports keyboard navigation', async () => {
  const user = userEvent.setup()

  render(<OrderForm onSubmit={jest.fn()} />)

  // Tab through form fields
  await user.tab()
  expect(screen.getByRole('textbox', { name: 'Product Name' })).toHaveFocus()

  await user.tab()
  expect(screen.getByRole('spinbutton', { name: 'Quantity' })).toHaveFocus()

  await user.tab()
  expect(screen.getByRole('combobox', { name: 'Shipping' })).toHaveFocus()

  await user.tab()
  expect(screen.getByRole('button', { name: 'Place Order' })).toHaveFocus()
})
```

## Hover and Tooltip

```tsx
it('shows tooltip on hover', async () => {
  const user = userEvent.setup()

  render(<InfoIcon tooltip="Additional details about pricing" />)

  await user.hover(screen.getByRole('img', { name: 'Info' }))

  expect(screen.getByRole('tooltip')).toHaveTextContent(
    'Additional details about pricing'
  )

  await user.unhover(screen.getByRole('img', { name: 'Info' }))

  expect(screen.queryByRole('tooltip')).not.toBeInTheDocument()
})
```

## Drag and Drop

```tsx
it('reorders items via drag and drop', async () => {
  const user = userEvent.setup()

  render(<SortableList items={['A', 'B', 'C']} />)

  const itemA = screen.getByText('A')
  const itemC = screen.getByText('C')

  await user.pointer([
    { keys: '[MouseLeft>]', target: itemA },
    { target: itemC },
    { keys: '[/MouseLeft]' },
  ])

  const items = screen.getAllByRole('listitem')
  expect(items[0]).toHaveTextContent('B')
  expect(items[2]).toHaveTextContent('A')
})
```

## Anti-Patterns

**Not awaiting userEvent calls:**
```tsx
// Bad: userEvent is async
user.click(screen.getByRole('button'))
expect(handleClick).toHaveBeenCalled()  // May fail intermittently

// Good
await user.click(screen.getByRole('button'))
expect(handleClick).toHaveBeenCalled()
```

**Using fireEvent for standard interactions:**
```tsx
// Bad: misses focus, blur, and intermediate events
fireEvent.click(screen.getByRole('button'))

// Good: simulates complete interaction
await user.click(screen.getByRole('button'))
```

**Testing internal event handler names:**
```tsx
// Bad
expect(component.props.onClick).toBeDefined()

// Good: test the behavior
await user.click(screen.getByRole('button'))
expect(screen.getByText('Clicked!')).toBeInTheDocument()
```
