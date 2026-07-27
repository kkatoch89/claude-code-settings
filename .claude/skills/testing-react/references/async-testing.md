# Async Testing

Testing asynchronous operations, data fetching, loading states, and timed behavior.

## waitFor

Use `waitFor` when you need to wait for an assertion to pass after an async operation.

```tsx
import { render, screen, waitFor } from '@testing-library/react'

it('loads and displays order data', async () => {
  render(<OrderDetails orderId="123" />)

  // Shows loading state initially
  expect(screen.getByRole('status')).toHaveTextContent('Loading...')

  // Waits for data to load
  await waitFor(() => {
    expect(screen.getByRole('heading', { name: 'Order #123' })).toBeInTheDocument()
  })

  // Loading state is gone
  expect(screen.queryByRole('status')).not.toBeInTheDocument()
})
```

### waitFor options

```tsx
await waitFor(
  () => {
    expect(screen.getByText('Success')).toBeInTheDocument()
  },
  {
    timeout: 3000,     // Max time to wait (default: 1000ms)
    interval: 100,     // Polling interval (default: 50ms)
  }
)
```

## findBy Queries

`findBy` queries combine `getBy` with `waitFor`. Preferred for waiting on elements to appear.

```tsx
it('shows success message after submission', async () => {
  const user = userEvent.setup()

  render(<OrderForm onSubmit={mockSubmit} />)

  await user.type(screen.getByRole('textbox', { name: 'Email' }), 'alice@example.com')
  await user.click(screen.getByRole('button', { name: 'Submit' }))

  // findBy = getBy + waitFor
  const successMessage = await screen.findByRole('alert', { name: /success/i })
  expect(successMessage).toHaveTextContent('Order placed successfully')
})
```

### findBy vs waitFor

```tsx
// Prefer findBy when waiting for an element to appear
const alert = await screen.findByRole('alert')

// Use waitFor when:
// 1. Waiting for element to disappear
await waitFor(() => {
  expect(screen.queryByRole('status')).not.toBeInTheDocument()
})

// 2. Waiting for multiple conditions
await waitFor(() => {
  expect(screen.getByText('Success')).toBeInTheDocument()
  expect(handleSubmit).toHaveBeenCalled()
})

// 3. Asserting on non-DOM state
await waitFor(() => {
  expect(mockApi).toHaveBeenCalledWith({ orderId: '123' })
})
```

## Testing Loading States

```tsx
describe('OrderList', () => {
  it('shows loading skeleton while fetching', () => {
    render(<OrderList />)

    expect(screen.getByRole('status')).toBeInTheDocument()
    expect(screen.queryAllByRole('listitem')).toHaveLength(0)
  })

  it('shows orders after loading completes', async () => {
    render(<OrderList />)

    const orders = await screen.findAllByRole('listitem')
    expect(orders).toHaveLength(3)
    expect(screen.queryByRole('status')).not.toBeInTheDocument()
  })

  it('shows error state on fetch failure', async () => {
    server.use(
      rest.get('/api/orders', (req, res, ctx) =>
        res(ctx.status(500))
      )
    )

    render(<OrderList />)

    await screen.findByRole('alert')
    expect(screen.getByText(/failed to load/i)).toBeInTheDocument()
    expect(screen.getByRole('button', { name: 'Retry' })).toBeInTheDocument()
  })
})
```

## Mocking API Calls with MSW

Mock Service Worker (MSW) intercepts network requests at the service worker level, providing realistic API mocking.

### Setup

```tsx
// src/mocks/handlers.ts
import { rest } from 'msw'

export const handlers = [
  rest.get('/api/orders', (req, res, ctx) => {
    return res(
      ctx.json([
        { id: '1', status: 'pending', total: 4200 },
        { id: '2', status: 'confirmed', total: 8400 },
      ])
    )
  }),

  rest.post('/api/orders', async (req, res, ctx) => {
    const body = await req.json()
    return res(
      ctx.status(201),
      ctx.json({ id: '3', ...body, status: 'pending' })
    )
  }),
]

// src/mocks/server.ts
import { setupServer } from 'msw/node'
import { handlers } from './handlers'

export const server = setupServer(...handlers)
```

### Test setup

```tsx
// jest.setup.ts or setupTests.ts
import { server } from './mocks/server'

beforeAll(() => server.listen({ onUnhandledRequest: 'error' }))
afterEach(() => server.resetHandlers())
afterAll(() => server.close())
```

### Override handlers per test

```tsx
it('handles empty order list', async () => {
  server.use(
    rest.get('/api/orders', (req, res, ctx) => {
      return res(ctx.json([]))
    })
  )

  render(<OrderList />)

  await screen.findByText('No orders found')
})

it('handles network errors', async () => {
  server.use(
    rest.get('/api/orders', (req, res) => {
      return res.networkError('Failed to connect')
    })
  )

  render(<OrderList />)

  await screen.findByRole('alert')
  expect(screen.getByText(/network error/i)).toBeInTheDocument()
})
```

## Testing Debounced Input

```tsx
it('debounces search input', async () => {
  jest.useFakeTimers()
  const user = userEvent.setup({ advanceTimers: jest.advanceTimersByTime })

  render(<SearchOrders />)

  await user.type(screen.getByRole('searchbox'), 'widget')

  // API not called yet (debounce period)
  expect(screen.queryByRole('listitem')).not.toBeInTheDocument()

  // Advance past debounce delay
  act(() => {
    jest.advanceTimersByTime(300)
  })

  // Now results appear
  await screen.findByText('Widget Pro')

  jest.useRealTimers()
})
```

## Testing Timers

```tsx
it('auto-refreshes data every 30 seconds', async () => {
  jest.useFakeTimers()

  render(<OrderDashboard />)

  await screen.findByText('3 orders')

  // Update mock data
  server.use(
    rest.get('/api/orders', (req, res, ctx) =>
      res(ctx.json([...initialOrders, newOrder]))
    )
  )

  // Advance timer past refresh interval
  act(() => {
    jest.advanceTimersByTime(30_000)
  })

  await screen.findByText('4 orders')

  jest.useRealTimers()
})
```

## Testing WebSocket / Real-time Updates

```tsx
it('displays real-time order updates', async () => {
  render(<OrderFeed />)

  await screen.findByText('Connected')

  // Simulate incoming message
  act(() => {
    mockWebSocket.emit('message', {
      type: 'order_created',
      data: { id: '456', status: 'pending' },
    })
  })

  expect(screen.getByText('Order #456')).toBeInTheDocument()
})
```

## Anti-Patterns

**Not testing loading states:**
```tsx
// Bad: only tests the final state
it('shows orders', async () => {
  render(<OrderList />)
  await screen.findAllByRole('listitem')
})

// Good: tests the full lifecycle
it('shows loading then orders', async () => {
  render(<OrderList />)
  expect(screen.getByRole('status')).toBeInTheDocument()
  await screen.findAllByRole('listitem')
  expect(screen.queryByRole('status')).not.toBeInTheDocument()
})
```

**Using arbitrary delays instead of waitFor:**
```tsx
// Bad: fragile, slow
await new Promise(r => setTimeout(r, 1000))
expect(screen.getByText('Success')).toBeInTheDocument()

// Good: polls until assertion passes
await waitFor(() => {
  expect(screen.getByText('Success')).toBeInTheDocument()
})
```

**Forgetting to clean up fake timers:**
```tsx
// Bad: leaks into other tests
jest.useFakeTimers()
// ... test code

// Good: always restore
jest.useFakeTimers()
// ... test code
jest.useRealTimers()  // or use afterEach
```
