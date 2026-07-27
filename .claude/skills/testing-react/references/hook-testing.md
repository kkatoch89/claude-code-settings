# Hook Testing

Testing custom React hooks with renderHook and act.

## When to Test Hooks Directly

Test hooks directly when:
- The hook is a shared utility used by multiple components
- The hook has complex state logic worth testing in isolation
- Testing through a component would require excessive setup

Test hooks through components when:
- The hook is used by only one component
- The hook's behavior is fully visible in the component's rendered output
- The hook is simple (e.g., a thin wrapper around useState)

## Basic Hook Testing

```tsx
import { renderHook, act } from '@testing-library/react'
import { useCounter } from './useCounter'

describe('useCounter', () => {
  it('starts with initial value', () => {
    const { result } = renderHook(() => useCounter(10))

    expect(result.current.count).toBe(10)
  })

  it('defaults to zero', () => {
    const { result } = renderHook(() => useCounter())

    expect(result.current.count).toBe(0)
  })

  it('increments the count', () => {
    const { result } = renderHook(() => useCounter(0))

    act(() => {
      result.current.increment()
    })

    expect(result.current.count).toBe(1)
  })

  it('decrements the count', () => {
    const { result } = renderHook(() => useCounter(5))

    act(() => {
      result.current.decrement()
    })

    expect(result.current.count).toBe(4)
  })

  it('resets to initial value', () => {
    const { result } = renderHook(() => useCounter(10))

    act(() => {
      result.current.increment()
      result.current.increment()
    })

    expect(result.current.count).toBe(12)

    act(() => {
      result.current.reset()
    })

    expect(result.current.count).toBe(10)
  })
})
```

## Testing Hooks with Dependencies

```tsx
describe('useFilteredOrders', () => {
  it('filters orders by status', () => {
    const orders = [
      { id: '1', status: 'pending' },
      { id: '2', status: 'confirmed' },
      { id: '3', status: 'pending' },
    ]

    const { result } = renderHook(() =>
      useFilteredOrders(orders, 'pending')
    )

    expect(result.current).toHaveLength(2)
    expect(result.current.every(o => o.status === 'pending')).toBe(true)
  })

  it('updates when filter changes', () => {
    const orders = [
      { id: '1', status: 'pending' },
      { id: '2', status: 'confirmed' },
    ]

    const { result, rerender } = renderHook(
      ({ status }) => useFilteredOrders(orders, status),
      { initialProps: { status: 'pending' } }
    )

    expect(result.current).toHaveLength(1)

    rerender({ status: 'confirmed' })

    expect(result.current).toHaveLength(1)
    expect(result.current[0].id).toBe('2')
  })
})
```

## Testing Async Hooks

```tsx
describe('useOrders', () => {
  it('fetches and returns orders', async () => {
    const { result } = renderHook(() => useOrders())

    // Initial loading state
    expect(result.current.isLoading).toBe(true)
    expect(result.current.orders).toEqual([])

    // Wait for data to load
    await waitFor(() => {
      expect(result.current.isLoading).toBe(false)
    })

    expect(result.current.orders).toHaveLength(2)
    expect(result.current.error).toBeNull()
  })

  it('handles fetch errors', async () => {
    server.use(
      rest.get('/api/orders', (req, res, ctx) =>
        res(ctx.status(500))
      )
    )

    const { result } = renderHook(() => useOrders())

    await waitFor(() => {
      expect(result.current.isLoading).toBe(false)
    })

    expect(result.current.error).toBeTruthy()
    expect(result.current.orders).toEqual([])
  })

  it('refetches when refresh is called', async () => {
    const { result } = renderHook(() => useOrders())

    await waitFor(() => {
      expect(result.current.isLoading).toBe(false)
    })

    // Update server data
    server.use(
      rest.get('/api/orders', (req, res, ctx) =>
        res(ctx.json([...initialOrders, newOrder]))
      )
    )

    act(() => {
      result.current.refresh()
    })

    await waitFor(() => {
      expect(result.current.orders).toHaveLength(3)
    })
  })
})
```

## Testing Hooks with Context

Wrap the hook in the necessary providers:

```tsx
describe('useAuth', () => {
  const wrapper = ({ children }: { children: React.ReactNode }) => (
    <AuthProvider>
      {children}
    </AuthProvider>
  )

  it('returns current user', () => {
    const { result } = renderHook(() => useAuth(), { wrapper })

    expect(result.current.user).toBeDefined()
    expect(result.current.isAuthenticated).toBe(true)
  })

  it('handles logout', async () => {
    const { result } = renderHook(() => useAuth(), { wrapper })

    act(() => {
      result.current.logout()
    })

    expect(result.current.user).toBeNull()
    expect(result.current.isAuthenticated).toBe(false)
  })
})
```

## Testing Hooks with Effects

```tsx
describe('useDocumentTitle', () => {
  it('sets document title on mount', () => {
    renderHook(() => useDocumentTitle('Order Details'))

    expect(document.title).toBe('Order Details')
  })

  it('updates title when value changes', () => {
    const { rerender } = renderHook(
      ({ title }) => useDocumentTitle(title),
      { initialProps: { title: 'Page 1' } }
    )

    expect(document.title).toBe('Page 1')

    rerender({ title: 'Page 2' })

    expect(document.title).toBe('Page 2')
  })

  it('restores original title on unmount', () => {
    const originalTitle = document.title

    const { unmount } = renderHook(() => useDocumentTitle('Test'))

    expect(document.title).toBe('Test')

    unmount()

    expect(document.title).toBe(originalTitle)
  })
})
```

## Testing Hooks with Timers

```tsx
describe('useDebounce', () => {
  beforeEach(() => jest.useFakeTimers())
  afterEach(() => jest.useRealTimers())

  it('returns initial value immediately', () => {
    const { result } = renderHook(() => useDebounce('hello', 300))

    expect(result.current).toBe('hello')
  })

  it('debounces value changes', () => {
    const { result, rerender } = renderHook(
      ({ value }) => useDebounce(value, 300),
      { initialProps: { value: 'hello' } }
    )

    rerender({ value: 'world' })

    // Not yet updated
    expect(result.current).toBe('hello')

    act(() => {
      jest.advanceTimersByTime(300)
    })

    // Now updated
    expect(result.current).toBe('world')
  })

  it('resets timer on rapid changes', () => {
    const { result, rerender } = renderHook(
      ({ value }) => useDebounce(value, 300),
      { initialProps: { value: 'a' } }
    )

    rerender({ value: 'ab' })
    act(() => { jest.advanceTimersByTime(200) })

    rerender({ value: 'abc' })
    act(() => { jest.advanceTimersByTime(200) })

    // Still shows initial value (timer reset each time)
    expect(result.current).toBe('a')

    act(() => { jest.advanceTimersByTime(100) })

    // Now shows final value
    expect(result.current).toBe('abc')
  })
})
```

## Anti-Patterns

**Testing implementation details of hooks:**
```tsx
// Bad: checking internal state management
expect(result.current._internalCache).toBeDefined()

// Good: check the public API
expect(result.current.data).toEqual(expectedData)
```

**Not wrapping state updates in act:**
```tsx
// Bad: warning about state updates outside act
result.current.increment()

// Good
act(() => {
  result.current.increment()
})
```

**Testing hooks that should be tested through components:**
```tsx
// Bad: testing a single-use hook in isolation
const { result } = renderHook(() => useOrderFormState())

// Good: test through the component that uses it
render(<OrderForm />)
await user.type(screen.getByRole('textbox', { name: 'Email' }), 'test@example.com')
```
