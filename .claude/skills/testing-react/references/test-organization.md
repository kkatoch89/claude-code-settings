# Test Organization

File structure, helpers, setup patterns, and test suite management for React testing.

## File Structure

### Colocate tests with components (bulletproof-react pattern)

```
src/
  features/
    orders/
      components/
        OrderCard/
          OrderCard.tsx
          OrderCard.test.tsx
          OrderCard.stories.tsx
        OrderList/
          OrderList.tsx
          OrderList.test.tsx
      hooks/
        useOrders.ts
        useOrders.test.ts
      api/
        orders.ts
        orders.test.ts
  components/
    ui/
      Button/
        Button.tsx
        Button.test.tsx
  test/
    setup.ts
    helpers/
      render.tsx
      factories.ts
    mocks/
      handlers.ts
      server.ts
```

Convention: test files live next to the code they test, named `<Component>.test.tsx` or `<hook>.test.ts`.

Shared test utilities live in `src/test/` or `test/`.

## Test Setup

### Jest configuration

```ts
// jest.config.ts
export default {
  testEnvironment: 'jsdom',
  setupFilesAfterSetup: ['<rootDir>/src/test/setup.ts'],
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/src/$1',
  },
}
```

### Global setup file

```ts
// src/test/setup.ts
import '@testing-library/jest-dom'
import { server } from './mocks/server'

beforeAll(() => server.listen({ onUnhandledRequest: 'error' }))
afterEach(() => server.resetHandlers())
afterAll(() => server.close())
```

## Custom Render Function

Create a render wrapper that includes all necessary providers:

```tsx
// src/test/helpers/render.tsx
import { render, RenderOptions } from '@testing-library/react'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { AuthProvider } from '@/features/auth'
import { ThemeProvider } from '@/components/theme'

interface CustomRenderOptions extends Omit<RenderOptions, 'wrapper'> {
  user?: User
  queryClient?: QueryClient
}

function createTestQueryClient() {
  return new QueryClient({
    defaultOptions: {
      queries: {
        retry: false,
        gcTime: 0,
      },
    },
  })
}

export function renderWithProviders(
  ui: React.ReactElement,
  options: CustomRenderOptions = {}
) {
  const {
    user = mockUser,
    queryClient = createTestQueryClient(),
    ...renderOptions
  } = options

  function Wrapper({ children }: { children: React.ReactNode }) {
    return (
      <QueryClientProvider client={queryClient}>
        <AuthProvider user={user}>
          <ThemeProvider>
            {children}
          </ThemeProvider>
        </AuthProvider>
      </QueryClientProvider>
    )
  }

  return {
    ...render(ui, { wrapper: Wrapper, ...renderOptions }),
    queryClient,
  }
}

// Re-export everything from testing-library
export { screen, waitFor, within } from '@testing-library/react'
export { default as userEvent } from '@testing-library/user-event'
```

### Using the custom render

```tsx
import { renderWithProviders, screen, userEvent } from '@/test/helpers/render'

it('shows admin panel for admin users', () => {
  renderWithProviders(<Dashboard />, {
    user: { ...mockUser, role: 'admin' },
  })

  expect(screen.getByRole('region', { name: 'Admin Panel' })).toBeInTheDocument()
})
```

## Test Data Factories

```tsx
// src/test/helpers/factories.ts

let idCounter = 0

export function createOrder(overrides: Partial<Order> = {}): Order {
  return {
    id: String(++idCounter),
    status: 'pending',
    total: 4200,
    createdAt: new Date().toISOString(),
    items: [],
    ...overrides,
  }
}

export function createUser(overrides: Partial<User> = {}): User {
  return {
    id: String(++idCounter),
    name: 'Test User',
    email: `user-${idCounter}@example.com`,
    role: 'member',
    ...overrides,
  }
}

export function createOrderItem(overrides: Partial<OrderItem> = {}): OrderItem {
  return {
    id: String(++idCounter),
    productName: 'Widget',
    quantity: 1,
    price: 1000,
    ...overrides,
  }
}
```

### Usage in tests

```tsx
import { createOrder, createOrderItem } from '@/test/helpers/factories'

it('shows order with items', () => {
  const order = createOrder({
    items: [
      createOrderItem({ productName: 'Widget', quantity: 2, price: 1500 }),
      createOrderItem({ productName: 'Gadget', quantity: 1, price: 2500 }),
    ],
  })

  render(<OrderCard order={order} />)

  expect(screen.getByText('Widget')).toBeInTheDocument()
  expect(screen.getByText('Gadget')).toBeInTheDocument()
})
```

## Describe and It Block Conventions

### Group by component behavior

```tsx
describe('OrderForm', () => {
  describe('rendering', () => {
    it('shows all form fields', () => { /* ... */ })
    it('pre-fills values when editing', () => { /* ... */ })
  })

  describe('validation', () => {
    it('requires product name', async () => { /* ... */ })
    it('requires positive quantity', async () => { /* ... */ })
    it('shows inline errors on blur', async () => { /* ... */ })
  })

  describe('submission', () => {
    it('submits valid form data', async () => { /* ... */ })
    it('disables button while submitting', async () => { /* ... */ })
    it('shows success message on completion', async () => { /* ... */ })
    it('shows error message on failure', async () => { /* ... */ })
  })

  describe('accessibility', () => {
    it('has no a11y violations', async () => { /* ... */ })
    it('supports keyboard navigation', async () => { /* ... */ })
  })
})
```

### Name tests by behavior

```tsx
// Good: describes observable behavior
it('disables submit button when form is invalid')
it('shows error message after failed submission')
it('redirects to order list after successful creation')

// Bad: describes implementation
it('sets isSubmitting state to true')
it('calls handleError function')
it('dispatches NAVIGATE action')
```

## Jest Matchers for React Testing Library

### Common matchers from @testing-library/jest-dom

```tsx
// Presence
expect(element).toBeInTheDocument()
expect(element).not.toBeInTheDocument()

// Visibility
expect(element).toBeVisible()
expect(element).not.toBeVisible()

// State
expect(element).toBeEnabled()
expect(element).toBeDisabled()
expect(element).toBeChecked()
expect(element).toHaveFocus()

// Content
expect(element).toHaveTextContent('Order #123')
expect(element).toHaveTextContent(/order/i)

// Attributes
expect(element).toHaveAttribute('href', '/orders')
expect(element).toHaveAttribute('aria-expanded', 'true')

// Form values
expect(input).toHaveValue('alice@example.com')
expect(select).toHaveValue('express')

// Classes (use sparingly - prefer behavioral assertions)
expect(element).toHaveClass('active')
```

## Running Tests

```bash
# Run all tests
npm test

# Run tests for a specific file
npm test -- OrderCard.test.tsx

# Run tests matching a pattern
npm test -- --testPathPattern="orders"

# Run in watch mode
npm test -- --watch

# Run with coverage
npm test -- --coverage

# Run only changed tests
npm test -- --onlyChanged
```

## Anti-Patterns

**Test files far from source:**
```
# Bad: separate test directory mirroring src
tests/
  features/
    orders/
      OrderCard.test.tsx

# Good: colocated with component
src/features/orders/components/OrderCard/OrderCard.test.tsx
```

**Giant shared helper modules:**
```tsx
// Bad: 500-line TestUtils with everything
import { renderOrder, renderUser, mockRouter, mockAuth, ... } from 'test-utils'

// Good: focused helpers
import { renderWithProviders } from '@/test/helpers/render'
import { createOrder } from '@/test/helpers/factories'
```

**Not resetting state between tests:**
```tsx
// Bad: leaks state
let queryClient: QueryClient

beforeAll(() => {
  queryClient = new QueryClient()
})

// Good: fresh client per test
function createTestQueryClient() {
  return new QueryClient({ defaultOptions: { queries: { retry: false } } })
}
```
