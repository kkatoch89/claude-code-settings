# Oban Testing

Testing Oban workers, job scheduling, and queue behavior in ExUnit.

## Oban.Testing Setup

Oban provides `Oban.Testing` for test assertions. Configure Oban for testing in `config/test.exs`:

```elixir
# config/test.exs
config :my_app, Oban, testing: :manual
```

Testing modes:
- `:manual` -- Jobs are inserted but not executed. Use `Oban.drain_queue/2` to run them on demand.
- `:inline` -- Jobs execute immediately in the inserting process. Simple but loses async behavior.

### Import in test modules

```elixir
use Oban.Testing, repo: MyApp.Repo
```

This imports assertion helpers like `assert_enqueued/1` and `refute_enqueued/1`.

## Testing Worker Logic

### Unit testing perform/1

Test the worker's `perform/1` function directly to verify business logic:

```elixir
defmodule MyApp.Workers.OrderConfirmationTest do
  use MyApp.DataCase, async: true
  use Oban.Testing, repo: MyApp.Repo

  alias MyApp.Workers.OrderConfirmation

  describe "perform/1" do
    test "sends confirmation email for valid order" do
      order = insert(:order, status: :pending)

      assert :ok =
               perform_job(OrderConfirmation, %{order_id: order.id})

      assert Repo.get!(Order, order.id).status == :confirmed
    end

    test "returns error for missing order" do
      assert {:error, :not_found} =
               perform_job(OrderConfirmation, %{order_id: -1})
    end

    test "handles already-confirmed orders gracefully" do
      order = insert(:order, status: :confirmed)

      assert :ok =
               perform_job(OrderConfirmation, %{order_id: order.id})
    end
  end
end
```

`perform_job/2` builds a proper `%Oban.Job{}` struct and calls the worker's `perform/1`. This is the preferred way to test worker logic.

### Testing with job args validation

```elixir
test "validates required args" do
  assert {:error, _changeset} =
           OrderConfirmation.new(%{})
           |> Oban.insert()
end
```

## Testing Job Enqueuing

### assert_enqueued

Verify that a job was inserted with the expected arguments and options:

```elixir
test "enqueues confirmation job after checkout" do
  order = insert(:order)

  assert {:ok, _order} = Orders.checkout(order)

  assert_enqueued(
    worker: MyApp.Workers.OrderConfirmation,
    args: %{order_id: order.id}
  )
end
```

### assert_enqueued with options

```elixir
test "enqueues with correct queue and scheduling" do
  order = insert(:order)

  Orders.schedule_reminder(order)

  assert_enqueued(
    worker: MyApp.Workers.OrderReminder,
    args: %{order_id: order.id},
    queue: :email,
    scheduled_at: ~U[2024-01-15 10:00:00Z]
  )
end
```

### refute_enqueued

Verify that a job was NOT enqueued:

```elixir
test "does not enqueue confirmation for cancelled orders" do
  order = insert(:order, status: :cancelled)

  assert {:error, _reason} = Orders.checkout(order)

  refute_enqueued(worker: MyApp.Workers.OrderConfirmation)
end
```

## Draining Queues

Use `Oban.drain_queue/2` when testing end-to-end flows in `:manual` mode:

```elixir
test "processes order confirmation end-to-end" do
  order = insert(:order, status: :pending)

  # This enqueues the job
  Orders.checkout(order)

  # Execute all jobs in the queue
  assert %{success: 1, failure: 0} =
           Oban.drain_queue(queue: :default)

  # Verify the side effects
  assert Repo.get!(Order, order.id).status == :confirmed
end
```

### Draining with options

```elixir
# Drain a specific queue
Oban.drain_queue(queue: :email)

# Drain with a limit
Oban.drain_queue(queue: :default, with_limit: 5)

# Drain scheduled jobs as well
Oban.drain_queue(queue: :default, with_scheduled: true)
```

## Testing Retry Behavior

### Simulating failures

```elixir
test "retries on transient failure then succeeds" do
  order = insert(:order)

  # First attempt fails
  assert {:error, :temporary_failure} =
           perform_job(OrderConfirmation, %{
             order_id: order.id,
             attempt: 1
           })

  # Verify job would be retried (not discarded)
  # The worker should return {:error, reason} not {:discard, reason}
end

test "discards after permanent failure" do
  assert {:discard, :invalid_order} =
           perform_job(OrderConfirmation, %{order_id: -1, permanent: true})
end
```

### Testing max_attempts and backoff

```elixir
test "worker configured with correct retry settings" do
  assert OrderConfirmation.__opts__()[:max_attempts] == 5
  assert OrderConfirmation.__opts__()[:queue] == :default
end
```

## Testing Unique Jobs

```elixir
test "prevents duplicate jobs for the same order" do
  order = insert(:order)

  assert {:ok, %Oban.Job{}} =
           OrderConfirmation.new(%{order_id: order.id})
           |> Oban.insert()

  # Second insert returns existing job
  assert {:ok, %Oban.Job{conflict?: true}} =
           OrderConfirmation.new(%{order_id: order.id})
           |> Oban.insert()
end
```

## Testing with async: false

Oban jobs that run in separate processes need shared sandbox mode:

```elixir
defmodule MyApp.Workers.OrderConfirmationIntegrationTest do
  use MyApp.DataCase, async: false
  use Oban.Testing, repo: MyApp.Repo

  test "full job lifecycle" do
    order = insert(:order, status: :pending)

    {:ok, _job} =
      OrderConfirmation.new(%{order_id: order.id})
      |> Oban.insert()

    # Drain executes the job in a separate process
    assert %{success: 1, failure: 0} =
             Oban.drain_queue(queue: :default)

    assert Repo.get!(Order, order.id).status == :confirmed
  end
end
```

Use `async: false` when:
- Using `Oban.drain_queue/2` (jobs execute in separate processes)
- Testing job interactions that spawn processes
- Testing Oban Pro features like workflows

Use `async: true` when:
- Only calling `perform_job/2` directly (runs in the test process)
- Only asserting on enqueued/refuted jobs without draining

## Anti-Patterns

**Testing Oban internals instead of worker behavior:**
```elixir
# Bad: testing Oban's job insertion mechanism
test "inserts job into oban_jobs table" do
  Oban.insert(OrderConfirmation.new(%{order_id: 1}))
  assert Repo.one(Oban.Job)
end
```
Instead, use `assert_enqueued/1` and test the worker's `perform/1` directly.

**Using :inline mode for everything:**
```elixir
# Bad: inline mode hides async issues
config :my_app, Oban, testing: :inline
```
Prefer `:manual` mode with explicit `drain_queue` calls to maintain control over when jobs execute.

**Not testing error return values:**
```elixir
# Bad: only testing the happy path
test "processes order" do
  order = insert(:order)
  assert :ok = perform_job(OrderConfirmation, %{order_id: order.id})
end
```
Instead, test all return paths: `:ok`, `{:error, reason}`, `{:discard, reason}`, and `{:snooze, seconds}`.
