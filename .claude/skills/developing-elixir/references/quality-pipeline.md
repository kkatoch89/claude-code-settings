# Quality Pipeline Reference

Sequential validation pipeline for ensuring Elixir code quality. Run these steps in order -- each step must pass before proceeding to the next.

## Pipeline Overview

```
mix compile --warnings-as-errors
        |
        v
    mix format
        |
        v
    mix credo
        |
        v
   mix dialyzer
```

Each step catches a different class of issues. Running them in sequence ensures problems are caught at the earliest, cheapest stage.

## Step 1: Compilation with Warnings as Errors

```bash
mix compile --warnings-as-errors
```

**What it catches:**
- Unused variables and imports
- Missing function clauses
- Deprecated function usage
- Pattern match warnings
- Unreachable code
- Undefined function calls
- Module attribute issues

**Fix strategy:**
- Address each warning individually
- Prefix unused variables with underscore: `_unused`
- Remove unused imports and aliases
- Update deprecated function calls to their replacements
- Fix unreachable code paths

**Common warnings and fixes:**

```elixir
# Warning: variable "result" is unused
# Fix: prefix with underscore
_result = some_function()

# Warning: function head is never used
# Fix: remove the unused clause or add @doc false
@doc false
def unused_helper, do: :ok

# Warning: Module.deprecated_fn/1 is deprecated
# Fix: use the replacement function
Module.new_fn(arg)
```

## Step 2: Code Formatting

```bash
mix format
```

**What it enforces:**
- Consistent indentation (2 spaces)
- Line length limits
- Trailing comma conventions
- Parentheses usage
- Pipeline formatting
- Keyword list formatting

**Configuration** (`.formatter.exs`):

```elixir
[
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  line_length: 98,
  import_deps: [:ecto, :ecto_sql, :phoenix],
  plugins: [Phoenix.LiveView.HTMLFormatter],
  subdirectories: ["priv/*/migrations"]
]
```

**Check-only mode** (for CI):

```bash
mix format --check-formatted
```

This returns a non-zero exit code if any files need formatting, without modifying them.

## Step 3: Static Analysis with Credo

```bash
mix credo
```

**What it catches:**
- Code consistency issues (naming, aliasing)
- Code readability concerns (complexity, nesting depth)
- Refactoring opportunities (duplicated code, long functions)
- Software design issues (module structure, function length)
- Warning-level issues (TODO/FIXME comments, debugging code)

**Strictness levels:**

```bash
# Default: normal checks
mix credo

# Strict: includes lower-priority suggestions
mix credo --strict

# Only specific category
mix credo --checks-with-tag design

# Explain a specific issue
mix credo explain MyApp.SomeModule
```

**Common Credo checks and fixes:**

```elixir
# Credo.Check.Readability.ModuleDoc -- missing @moduledoc
# Fix: add module documentation
defmodule MyApp.Orders do
  @moduledoc """
  Context module for order management.
  """
end

# Credo.Check.Refactor.CyclomaticComplexity -- function too complex
# Fix: extract helper functions to reduce branching

# Credo.Check.Design.AliasUsage -- use alias instead of full module name
# Fix:
alias MyApp.Accounts.User
# instead of referencing MyApp.Accounts.User everywhere

# Credo.Check.Consistency.ParameterPatternMatching -- inconsistent pattern placement
# Fix: always pattern match in function head, not in body
def process(%Order{status: :pending} = order), do: ...
```

**Configuration** (`.credo.exs`):

```elixir
%{
  configs: [
    %{
      name: "default",
      strict: false,
      checks: %{
        enabled: [
          {Credo.Check.Readability.ModuleDoc, []},
          {Credo.Check.Refactor.CyclomaticComplexity, [max_complexity: 10]},
          {Credo.Check.Refactor.Nesting, [max_nesting: 3]}
          # ...
        ],
        disabled: [
          {Credo.Check.Readability.ModuleDoc, false}  # Disable specific check
        ]
      }
    }
  ]
}
```

## Step 4: Type Checking with Dialyzer

```bash
mix dialyzer
```

**What it catches:**
- Type specification violations
- Unreachable code based on types
- Pattern matches that will never succeed
- Function calls with wrong argument types
- Incorrect return types
- Contract violations between modules

**First run** builds the PLT (Persistent Lookup Table), which takes several minutes. Subsequent runs are faster.

**Common Dialyzer issues and fixes:**

```elixir
# The pattern can never match the type
# Fix: ensure all pattern match cases are reachable

# Function has no local return
# Fix: check that all code paths return a value matching the @spec

# Invalid type specification
# Fix: correct the @spec to match actual return values
@spec get_user(integer()) :: User.t() | nil
def get_user(id), do: Repo.get(User, id)

# The call will never return since it differs in argument types
# Fix: pass the correct argument types
```

**Adding type specs:**

```elixir
@spec calculate_total(list(LineItem.t())) :: non_neg_integer()
def calculate_total(items) do
  Enum.reduce(items, 0, fn item, acc -> acc + item.price * item.quantity end)
end

@type t :: %__MODULE__{
  id: integer() | nil,
  email: String.t(),
  name: String.t() | nil
}
```

**Configuration** (`mix.exs`):

```elixir
def project do
  [
    # ...
    dialyzer: [
      plt_add_deps: :app_tree,
      plt_add_apps: [:mix],
      flags: [
        :error_handling,
        :missing_return,
        :underspecs,
        :unmatched_returns
      ],
      ignore_warnings: ".dialyzer_ignore.exs"
    ]
  ]
end
```

## CI Integration

Run the full pipeline in CI:

```bash
mix compile --warnings-as-errors && \
mix format --check-formatted && \
mix credo --strict && \
mix dialyzer
```

Each step is a gate: if any step fails, the pipeline stops and reports the issue.

## Workflow Tips

- Run `mix compile --warnings-as-errors` frequently during development
- Run `mix format` on save (configure your editor)
- Run `mix credo` before committing
- Run `mix dialyzer` before pushing (it's the slowest step)
- Cache the Dialyzer PLT in CI for faster builds
