# Component Testing

Patterns for testing React components with React Testing Library.

## Basic Component Rendering

```tsx
import { render, screen } from '@testing-library/react'
import { OrderCard } from './OrderCard'

describe('OrderCard', () => {
  it('renders order details', () => {
    render(
      <OrderCard
        order={{ id: '123', status: 'pending', total: 4200 }}
      />
    )

    expect(screen.getByRole('heading', { name: 'Order #123' })).toBeInTheDocument()
    expect(screen.getByText('Pending')).toBeInTheDocument()
    expect(screen.getByText('$42.00')).toBeInTheDocument()
  })
})
```

## Testing Props

### Required props

```tsx
it('renders the user name', () => {
  render(<UserProfile name="Alice" email="alice@example.com" />)

  expect(screen.getByRole('heading', { name: 'Alice' })).toBeInTheDocument()
  expect(screen.getByText('alice@example.com')).toBeInTheDocument()
})
```

### Optional props with defaults

```tsx
it('shows default avatar when none provided', () => {
  render(<UserProfile name="Alice" email="alice@example.com" />)

  expect(screen.getByAltText('User avatar')).toHaveAttribute(
    'src',
    expect.stringContaining('default-avatar')
  )
})

it('shows custom avatar when provided', () => {
  render(
    <UserProfile
      name="Alice"
      email="alice@example.com"
      avatarUrl="/alice.jpg"
    />
  )

  expect(screen.getByAltText('User avatar')).toHaveAttribute('src', '/alice.jpg')
})
```

### Callback props

```tsx
it('calls onSelect when order is clicked', async () => {
  const handleSelect = jest.fn()
  const user = userEvent.setup()

  render(
    <OrderCard
      order={{ id: '123', status: 'pending', total: 4200 }}
      onSelect={handleSelect}
    />
  )

  await user.click(screen.getByRole('button', { name: 'Select order' }))

  expect(handleSelect).toHaveBeenCalledWith('123')
  expect(handleSelect).toHaveBeenCalledTimes(1)
})
```

## Conditional Rendering

```tsx
describe('OrderStatus', () => {
  it('shows success message for confirmed orders', () => {
    render(<OrderStatus status="confirmed" />)

    expect(screen.getByRole('alert')).toHaveTextContent('Order confirmed')
    expect(screen.queryByRole('button', { name: 'Retry' })).not.toBeInTheDocument()
  })

  it('shows error message and retry button for failed orders', () => {
    render(<OrderStatus status="failed" />)

    expect(screen.getByRole('alert')).toHaveTextContent('Order failed')
    expect(screen.getByRole('button', { name: 'Retry' })).toBeInTheDocument()
  })

  it('shows loading spinner for pending orders', () => {
    render(<OrderStatus status="pending" />)

    expect(screen.getByRole('status')).toBeInTheDocument()
    expect(screen.queryByRole('alert')).not.toBeInTheDocument()
  })
})
```

## Testing Lists

```tsx
it('renders a list of orders', () => {
  const orders = [
    { id: '1', status: 'pending', total: 1000 },
    { id: '2', status: 'confirmed', total: 2000 },
    { id: '3', status: 'shipped', total: 3000 },
  ]

  render(<OrderList orders={orders} />)

  const items = screen.getAllByRole('listitem')
  expect(items).toHaveLength(3)
  expect(items[0]).toHaveTextContent('Order #1')
  expect(items[2]).toHaveTextContent('Order #3')
})

it('shows empty state when no orders exist', () => {
  render(<OrderList orders={[]} />)

  expect(screen.queryAllByRole('listitem')).toHaveLength(0)
  expect(screen.getByText('No orders found')).toBeInTheDocument()
})
```

## Testing with Context Providers

```tsx
const renderWithProviders = (ui: React.ReactElement, options?: {
  user?: User
  theme?: 'light' | 'dark'
}) => {
  const { user = mockUser, theme = 'light' } = options ?? {}

  return render(
    <ThemeProvider theme={theme}>
      <AuthProvider user={user}>
        {ui}
      </AuthProvider>
    </ThemeProvider>
  )
}

it('shows admin controls for admin users', () => {
  renderWithProviders(<Dashboard />, {
    user: { ...mockUser, role: 'admin' },
  })

  expect(screen.getByRole('button', { name: 'Manage Users' })).toBeInTheDocument()
})

it('hides admin controls for regular users', () => {
  renderWithProviders(<Dashboard />, {
    user: { ...mockUser, role: 'member' },
  })

  expect(screen.queryByRole('button', { name: 'Manage Users' })).not.toBeInTheDocument()
})
```

## Testing Error Boundaries

```tsx
it('renders fallback UI when child component throws', () => {
  const ThrowingComponent = () => {
    throw new Error('Test error')
  }

  // Suppress console.error for expected errors
  const consoleSpy = jest.spyOn(console, 'error').mockImplementation()

  render(
    <ErrorBoundary fallback={<div>Something went wrong</div>}>
      <ThrowingComponent />
    </ErrorBoundary>
  )

  expect(screen.getByText('Something went wrong')).toBeInTheDocument()
  consoleSpy.mockRestore()
})
```

## Testing Accessibility

```tsx
it('has no accessibility violations', async () => {
  const { container } = render(<OrderForm />)

  const results = await axe(container)
  expect(results).toHaveNoViolations()
})

it('manages focus correctly after submission', async () => {
  const user = userEvent.setup()
  render(<OrderForm />)

  await user.click(screen.getByRole('button', { name: 'Submit' }))

  expect(screen.getByRole('alert')).toHaveFocus()
})

it('announces status changes to screen readers', () => {
  render(<OrderStatus status="confirmed" />)

  const alert = screen.getByRole('alert')
  expect(alert).toHaveAttribute('aria-live', 'polite')
})
```

## Snapshot Testing (Use Sparingly)

Prefer explicit assertions over snapshots. When snapshots are appropriate:

```tsx
it('matches approved markup for email template', () => {
  const { container } = render(
    <EmailTemplate order={mockOrder} />
  )

  expect(container.firstChild).toMatchSnapshot()
})
```

Use snapshots only for:
- Markup-sensitive outputs (email templates, SSR)
- Regression guarding on stable, rarely-changing components
- Never for large component trees or frequently-changing UI

## Anti-Patterns

**Testing implementation details:**
```tsx
// Bad: accessing component internals
const { result } = renderHook(() => useOrderState())
expect(result.current.internalState).toBe('loading')

// Good: test what the user sees
render(<OrderCard order={mockOrder} />)
expect(screen.getByText('Loading...')).toBeInTheDocument()
```

**Over-specific assertions:**
```tsx
// Bad: breaks on any styling change
expect(screen.getByText('Submit')).toHaveClass('btn btn-primary mt-4')

// Good: test behavior, not styling
expect(screen.getByRole('button', { name: 'Submit' })).toBeEnabled()
```

**Testing third-party library behavior:**
```tsx
// Bad: testing that React Router works
expect(window.location.pathname).toBe('/orders/123')

// Good: test that your code navigates correctly
expect(screen.getByRole('link', { name: 'Order #123' })).toHaveAttribute(
  'href',
  '/orders/123'
)
```
