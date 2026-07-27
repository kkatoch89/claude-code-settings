# Oban Patterns Reference

Expert guidance for background job processing with Oban in Elixir applications, covering worker implementation, retry strategies, queue management, and telemetry.

## Quick Start

```elixir
defmodule MyApp.Workers.SendWelcomeEmail do
  use Oban.Worker, queue: :mailers, max_attempts: 3

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"user_id" => user_id}}) do
    user = MyApp.Accounts.get_user!(user_id)
    MyApp.Mailer.deliver_welcome(user)
  end
end

# Enqueue a job
%{user_id: user.id}
|> MyApp.Workers.SendWelcomeEmail.new()
|> Oban.insert()
```

## Worker Implementation

### Basic Worker Pattern

Every Oban worker implements the `perform/1` callback, receiving an `%Oban.Job{}` struct.

```elixir
defmodule MyApp.Workers.ProcessOrder do
  use Oban.Worker,
    queue: :orders,
    max_attempts: 5,
    unique: [period: 60, fields: [:args, :queue]]

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"order_id" => order_id}, attempt: attempt}) do
    case MyApp.Orders.process(order_id) do
      {:ok, _order} -> :ok
      {:error, :not_found} -> {:cancel, "Order #{order_id} not found"}
      {:error, :payment_failed} when attempt < 5 -> {:error, "Payment failed, will retry"}
      {:error, :payment_failed} -> {:cancel, "Payment failed after all attempts"}
    end
  end
end
```

### Worker Return Values

- `:ok` -- Job completed successfully
- `{:ok, result}` -- Job completed successfully (result is ignored but useful for testing)
- `{:error, reason}` -- Job failed, will be retried if attempts remain
- `{:cancel, reason}` -- Job cancelled permanently, will not be retried
- `{:snooze, seconds}` -- Job rescheduled to run after the given number of seconds

### Worker Options

```elixir
use Oban.Worker,
  queue: :default,          # Queue name (atom)
  max_attempts: 20,         # Maximum retry attempts (default: 20)
  priority: 0,              # 0 (highest) to 9 (lowest), default 0
  unique: [                 # Uniqueness constraints
    period: 300,            # Unique within 300 seconds
    fields: [:args, :queue, :worker],
    keys: [:user_id],       # Only check specific arg keys
    states: [:available, :scheduled, :executing]
  ],
  tags: ["critical"]        # Metadata tags for filtering
```

## Retry Strategies

### Default Exponential Backoff

Oban uses exponential backoff by default: `attempt^4 + 6` seconds between retries.

### Custom Backoff

```elixir
defmodule MyApp.Workers.ExternalApiCall do
  use Oban.Worker, queue: :external, max_attempts: 10

  @impl Oban.Worker
  def backoff(%Oban.Job{attempt: attempt}) do
    # Linear backoff: 30 seconds per attempt
    attempt * 30
  end

  @impl Oban.Worker
  def perform(%Oban.Job{args: args}) do
    # ... implementation
  end
end
```

### Retry Pattern by Error Type

```elixir
@impl Oban.Worker
def perform(%Oban.Job{args: %{"url" => url}}) do
  case HTTPClient.get(url) do
    {:ok, %{status: 200, body: body}} ->
      process_response(body)

    {:ok, %{status: 429}} ->
      # Rate limited -- snooze and retry later
      {:snooze, 60}

    {:ok, %{status: status}} when status in [500, 502, 503] ->
      # Server error -- retry with backoff
      {:error, "Server returned #{status}"}

    {:ok, %{status: 404}} ->
      # Not found -- don't retry
      {:cancel, "Resource not found"}

    {:error, %{reason: :timeout}} ->
      {:error, "Request timed out"}

    {:error, reason} ->
      {:cancel, "Permanent failure: #{inspect(reason)}"}
  end
end
```

## Queue Management

### Configuration

```elixir
# config/config.exs
config :my_app, Oban,
  repo: MyApp.Repo,
  queues: [
    default: 10,          # 10 concurrent workers
    mailers: 20,          # Email sending
    orders: 5,            # Order processing (limited for rate control)
    external: 3,          # External API calls (conservative)
    media: [limit: 2, paused: false]  # Heavy processing
  ],
  plugins: [
    Oban.Plugins.Pruner,              # Clean completed jobs
    {Oban.Plugins.Cron, crontab: [    # Scheduled jobs
      {"0 * * * *", MyApp.Workers.HourlyReport},
      {"0 0 * * *", MyApp.Workers.DailyCleanup, args: %{type: "expired"}},
      {"*/5 * * * *", MyApp.Workers.HealthCheck}
    ]},
    {Oban.Plugins.Lifeline, rescue_after: :timer.minutes(30)}
  ]
```

### Queue Priority

```elixir
# High priority job (processed first)
%{order_id: order.id}
|> MyApp.Workers.ProcessOrder.new(priority: 0)
|> Oban.insert()

# Low priority job (processed after higher priority)
%{report_type: "weekly"}
|> MyApp.Workers.GenerateReport.new(priority: 5)
|> Oban.insert()
```

### Scheduling Jobs

```elixir
# Schedule for later
%{user_id: user.id}
|> MyApp.Workers.SendReminder.new(scheduled_at: DateTime.add(DateTime.utc_now(), 3600))
|> Oban.insert()

# Schedule with Oban.insert_all for bulk
jobs =
  Enum.map(user_ids, fn user_id ->
    MyApp.Workers.SendNotification.new(%{user_id: user_id})
  end)

Oban.insert_all(jobs)
```

### Unique Jobs

```elixir
defmodule MyApp.Workers.SyncUser do
  use Oban.Worker,
    queue: :sync,
    unique: [
      period: 300,              # 5 minute window
      fields: [:args, :queue],  # Unique by args + queue combo
      keys: [:user_id],         # Only check user_id in args
      states: [:available, :scheduled, :executing, :retryable]
    ]

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"user_id" => user_id}}) do
    MyApp.Sync.sync_user(user_id)
  end
end
```

## Telemetry and Monitoring

### Attaching Telemetry Handlers

```elixir
defmodule MyApp.ObanTelemetry do
  require Logger

  def attach do
    :telemetry.attach_many(
      "oban-logger",
      [
        [:oban, :job, :start],
        [:oban, :job, :stop],
        [:oban, :job, :exception]
      ],
      &__MODULE__.handle_event/4,
      nil
    )
  end

  def handle_event([:oban, :job, :start], _measure, meta, _config) do
    Logger.info("[Oban] Starting #{meta.worker} (attempt #{meta.attempt})")
  end

  def handle_event([:oban, :job, :stop], measure, meta, _config) do
    Logger.info(
      "[Oban] Completed #{meta.worker} in #{System.convert_time_unit(measure.duration, :native, :millisecond)}ms"
    )
  end

  def handle_event([:oban, :job, :exception], _measure, meta, _config) do
    Logger.error(
      "[Oban] Failed #{meta.worker} (attempt #{meta.attempt}): #{inspect(meta.reason)}"
    )
  end
end
```

### Metrics Integration

```elixir
# In application.ex, attach telemetry on startup
def start(_type, _args) do
  MyApp.ObanTelemetry.attach()
  # ...
end
```

### Key Telemetry Events

- `[:oban, :job, :start]` -- Job execution begins
- `[:oban, :job, :stop]` -- Job execution completes successfully
- `[:oban, :job, :exception]` -- Job execution raises an exception
- `[:oban, :engine, :insert_job, :start | :stop]` -- Job insertion
- `[:oban, :plugin, :start | :stop | :exception]` -- Plugin lifecycle

## Testing Oban Workers

### Testing in Isolation

```elixir
defmodule MyApp.Workers.ProcessOrderTest do
  use MyApp.DataCase, async: true
  alias MyApp.Workers.ProcessOrder

  test "processes a valid order" do
    order = insert(:order, status: :pending)

    assert :ok = perform_job(ProcessOrder, %{order_id: order.id})
    assert Repo.get!(Order, order.id).status == :confirmed
  end

  test "cancels when order not found" do
    assert {:cancel, _reason} = perform_job(ProcessOrder, %{order_id: -1})
  end
end
```

### Using Oban.Testing

```elixir
# In config/test.exs
config :my_app, Oban, testing: :inline  # or :manual

# With :inline, jobs execute immediately when inserted
# With :manual, use Oban.drain_queue/1 to execute

# Assert a job was enqueued
use Oban.Testing, repo: MyApp.Repo

test "enqueues welcome email on registration" do
  {:ok, user} = Accounts.register(%{email: "test@example.com"})

  assert_enqueued worker: MyApp.Workers.SendWelcomeEmail,
                  args: %{user_id: user.id}
end

test "does not enqueue duplicate sync jobs" do
  Accounts.request_sync(user)
  Accounts.request_sync(user)

  assert [_single_job] = all_enqueued(worker: MyApp.Workers.SyncUser)
end
```

## Common Patterns

### Idempotent Workers

Design workers to be safely re-executed without side effects.

```elixir
@impl Oban.Worker
def perform(%Oban.Job{args: %{"order_id" => order_id}}) do
  order = MyApp.Orders.get_order!(order_id)

  # Guard against double-processing
  if order.status == :confirmed do
    :ok
  else
    MyApp.Orders.confirm(order)
  end
end
```

### Multi-step Workflows

```elixir
# Step 1: Process payment
defmodule MyApp.Workers.ProcessPayment do
  use Oban.Worker, queue: :payments

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"order_id" => order_id}}) do
    with {:ok, order} <- MyApp.Orders.charge_payment(order_id) do
      # Enqueue next step
      %{order_id: order.id}
      |> MyApp.Workers.FulfillOrder.new()
      |> Oban.insert()

      :ok
    end
  end
end
```

### Batch Processing

```elixir
defmodule MyApp.Workers.BatchNotify do
  use Oban.Worker, queue: :notifications

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"user_ids" => user_ids, "message" => message}}) do
    results =
      Enum.map(user_ids, fn user_id ->
        case MyApp.Notifications.send(user_id, message) do
          :ok -> {:ok, user_id}
          {:error, reason} -> {:error, user_id, reason}
        end
      end)

    failures = Enum.filter(results, &match?({:error, _, _}, &1))

    if Enum.empty?(failures) do
      :ok
    else
      # Re-enqueue only failed user IDs
      failed_ids = Enum.map(failures, fn {:error, id, _} -> id end)

      %{user_ids: failed_ids, message: message}
      |> __MODULE__.new(scheduled_at: DateTime.add(DateTime.utc_now(), 300))
      |> Oban.insert()

      :ok
    end
  end
end
```

## Anti-Patterns

- **Non-idempotent workers**: Always design for safe re-execution since retries are expected
- **Unbounded args**: Keep job args small; store large payloads in the database and pass IDs
- **Missing error classification**: Distinguish retryable errors from permanent failures using `{:error, ...}` vs `{:cancel, ...}`
- **No telemetry**: Always attach telemetry handlers for production visibility
- **Overly broad queues**: Separate workloads into dedicated queues for independent concurrency control
- **Testing without Oban.Testing**: Use `Oban.Testing` helpers for reliable, deterministic test assertions
