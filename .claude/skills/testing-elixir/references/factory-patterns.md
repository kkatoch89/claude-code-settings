# Factory Patterns Reference

Factory-first approach to test data setup in Elixir, covering ExMachina best practices, relationship building, and property-based testing with StreamData.

## Core Principle: Factory-First Data Setup

Always use factories with `insert()` to build complete relationship structures. Factories should be the primary mechanism for establishing test data, including all associations and relationships.

```elixir
# GOOD: Factory-based relationship setup
test "handles complex relationships" do
  user = insert(:user)
  organization = insert(:organization, owner: user)
  project = insert(:project, organization: organization)
  task = insert(:task, project: project, assignee: user)

  result = Tasks.complete(task.id)
  assert result.status == :completed
end
```

## Building Relationships with insert()

Use `insert()` to create associated records. Let the factory system handle foreign keys and association wiring.

### Direct Association

```elixir
# Factory defines the association
def order_factory do
  %MyApp.Orders.Order{
    status: :pending,
    user: build(:user),
    total: 0
  }
end

# In tests: override the association
test "order belongs to user" do
  user = insert(:user)
  order = insert(:order, user: user)

  assert order.user_id == user.id
end
```

### Deep Association Chains

```elixir
# Build a chain: user -> org -> project -> task
test "task inherits organization context" do
  user = insert(:user, role: :manager)
  org = insert(:organization, owner: user)
  project = insert(:project, organization: org, lead: user)
  task = insert(:task, project: project, assignee: user)

  assert {:ok, _} = Tasks.assign_reviewer(task, insert(:user))
end
```

### Multiple Related Records

```elixir
test "project with multiple tasks" do
  project = insert(:project)
  tasks = insert_list(5, :task, project: project)

  assert length(Projects.list_tasks(project)) == 5
end
```

## What to Avoid in Test Setup

### Do Not Use Repo.preload for Test Data

```elixir
# BAD: Using Repo.preload to wire up relationships
test "bad pattern" do
  user = insert(:user)
  order = insert(:order)
  order = Repo.preload(order, :user)
  # This doesn't actually set the relationship!
end

# GOOD: Use the factory association directly
test "good pattern" do
  user = insert(:user)
  order = insert(:order, user: user)
  # The relationship is set at insert time
end
```

### Do Not Use Manual Changesets for Test Setup

```elixir
# BAD: Manual changeset manipulation for test data
test "bad pattern" do
  user = insert(:user)
  {:ok, order} =
    %Order{}
    |> Ecto.Changeset.change(%{user_id: user.id, status: :pending})
    |> Repo.insert()
end

# GOOD: Factory handles it
test "good pattern" do
  user = insert(:user)
  order = insert(:order, user: user, status: :pending)
end
```

### Do Not Build Relationship Graphs in Factories

```elixir
# BAD: Factory builds entire object graph
def order_factory do
  user = build(:user)
  org = build(:organization, owner: user)
  products = build_list(5, :product, org: org)
  %Order{user: user, products: products, org: org}
end

# GOOD: Minimal factory, build graph in test
def order_factory do
  %Order{
    status: :pending,
    user: build(:user),
    total: 0
  }
end

# In the test that needs the full graph:
test "complex order scenario" do
  user = insert(:user)
  org = insert(:organization, owner: user)
  product = insert(:product, org: org)
  order = insert(:order, user: user, items: [build(:line_item, product: product)])
  # ...
end
```

## Factory Design Principles

### Minimal Valid Factories

Each factory should produce the minimum valid record. Override only what the specific test cares about.

```elixir
def user_factory do
  %User{
    name: "Jane",
    email: sequence(:email, &"user-#{&1}@example.com"),
    role: :member
  }
end

# Tests override only relevant fields
test "admins can delete projects" do
  admin = insert(:user, role: :admin)
  # name and email don't matter for this test
end
```

### Trait Factories for Common Variants

```elixir
def admin_factory do
  struct!(user_factory(), %{role: :admin})
end

def confirmed_user_factory do
  struct!(user_factory(), %{confirmed_at: DateTime.utc_now()})
end

# Usage
admin = insert(:admin)
confirmed = insert(:confirmed_user)
```

### Sequences for Unique Constraints

```elixir
def user_factory do
  %User{
    email: sequence(:email, &"user-#{&1}@example.com"),
    username: sequence(:username, &"user_#{&1}")
  }
end
```

## Property-Based Testing with StreamData

Use StreamData for generating test data when you need to verify invariants across many inputs.

### Basic Property Tests

```elixir
use ExUnitProperties

property "user email is always lowercased on save" do
  check all email <- email_generator() do
    {:ok, user} = Accounts.create_user(%{name: "Test", email: email})
    assert user.email == String.downcase(email)
  end
end

defp email_generator do
  gen all name <- string(:alphanumeric, min_length: 1),
          domain <- member_of(["example.com", "test.org", "mail.net"]) do
    "#{name}@#{domain}"
  end
end
```

### Custom Generators for Domain Types

```elixir
defp money_generator do
  gen all amount <- integer(0..999_999),
          currency <- member_of([:usd, :eur, :gbp]) do
    %{amount: amount, currency: currency}
  end
end

property "money addition is commutative" do
  check all a <- money_generator(),
            b <- money_generator(),
            a.currency == b.currency do
    assert Money.add(a, b) == Money.add(b, a)
  end
end
```

### Combining StreamData with Factories

```elixir
property "discount never exceeds order total" do
  check all total <- integer(1..100_000),
            discount_pct <- integer(0..100) do
    order = build(:order, total: total)
    discounted = Orders.apply_discount(order, discount_pct)
    assert discounted.total >= 0
    assert discounted.total <= total
  end
end
```

### When to Use StreamData vs ExMachina

| Use ExMachina (factories) when... | Use StreamData when... |
|-----------------------------------|------------------------|
| Testing specific business scenarios | Verifying invariants across many inputs |
| Building database-backed records | Testing pure functions |
| Need specific, named test data | Need to explore edge cases automatically |
| Relationships and associations matter | Input domain is large and varied |

## Test Data Setup Patterns

### Setup Block with Factories

```elixir
describe "order processing" do
  setup do
    user = insert(:user)
    product = insert(:product, price: 25_00, stock: 100)
    order = insert(:order, user: user, items: [
      build(:line_item, product: product, quantity: 2)
    ])

    %{user: user, product: product, order: order}
  end

  test "calculates correct total", %{order: order} do
    assert Orders.calculate_total(order) == 50_00
  end

  test "deducts inventory", %{order: order, product: product} do
    {:ok, _} = Orders.confirm(order)
    assert Products.stock(product.id) == 98
  end
end
```

### Inline Setup for Unique Tests

When a test needs unique data that isn't shared with other tests in the describe block, set it up inline.

```elixir
test "handles out-of-stock gracefully" do
  product = insert(:product, stock: 0)
  order = insert(:order, items: [build(:line_item, product: product, quantity: 1)])

  assert {:error, :out_of_stock} = Orders.confirm(order)
end
```

## Anti-Patterns

**Factories with too many overrides signal design issues:**
```elixir
# Bad: 10+ overrides needed to create valid test data
order = insert(:order,
  user: user, status: :pending, currency: :usd, region: :us,
  tax_rate: 0.08, shipping: :standard, coupon: nil, gift: false,
  expedited: false, subscription: false, trial: false
)
```
If you need many overrides, the schema might need restructuring.

**Using build() when insert() is needed for associations:**
```elixir
# Bad: build doesn't persist, so foreign keys aren't set
order = build(:order, user: build(:user))
Repo.get!(User, order.user_id)  # Fails! user_id is nil
```
Use `insert()` when the test needs persisted records with valid foreign keys.

**Shared factory state across test modules:**
```elixir
# Bad: global factory state
defmodule SharedSetup do
  def global_admin, do: insert(:user, role: :admin, email: "admin@test.com")
end
```
Each test should create its own data. Shared helpers should build fresh data each time.
