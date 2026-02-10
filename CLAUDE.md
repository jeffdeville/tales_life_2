# TalesLife2

Phoenix 1.8.1 / LiveView 1.1 / Ecto 3.13 / Tailwind v4 / esbuild / Bandit

## Build & Run

```bash
mix setup              # Install deps, create DB, setup assets
mix phx.server         # Start dev server
mix compile            # Compile without starting
mix compile --warnings-as-errors  # Strict compilation
```

## Test Commands

```bash
mix test                        # Run all tests (creates/migrates DB automatically)
mix test test/path/to/file.exs  # Run a specific test file
mix test --failed               # Re-run only previously failed tests
```

## Pre-commit

```bash
mix precommit   # Runs: compile --warnings-as-errors, deps.unlock --unused, format, test
```

Always run `mix precommit` before committing. Fix all warnings and test failures.

## Code Formatting

```bash
mix format                 # Format all files
mix format --check-formatted  # Check without modifying
```

Formatter is configured in `.formatter.exs` with `Phoenix.LiveView.HTMLFormatter` for HEEx support.

## Architecture

### Phoenix Contexts Pattern

Organize business logic into contexts (e.g., `TalesLife2.Accounts`, `TalesLife2.Interviews`). Contexts are the public API for a domain — LiveViews and controllers call context functions, never Repo directly.

### LiveView Naming

- LiveViews: `TalesLife2Web.SomethingLive` (suffix with `Live`)
- The default `:browser` scope is aliased with `TalesLife2Web`, so routes use: `live "/path", SomethingLive`
- Avoid LiveComponents unless there is a strong, specific need

### Module Organization

- One module per file — never nest multiple modules in the same file
- Web modules under `TalesLife2Web`, business logic under `TalesLife2`

## Coding Standards

### Elixir

- Use `Enum.at/2` for list index access — lists do not support `list[index]`
- Variables are immutable; rebind from block results: `socket = if ... do ... end`
- Use `Ecto.Changeset.get_field/2` to read changeset fields — no `changeset[:field]`
- Don't use `String.to_atom/1` on user input
- Predicate functions end with `?` (e.g., `valid?/1`), reserve `is_` prefix for guards only
- Use `Req` for HTTP requests — no HTTPoison, Tesla, or httpc
- Use stdlib `Date`, `DateTime`, `Time` for date/time — no extra deps

### Ecto

- Schema fields use `:string` type even for text columns
- Always preload associations that will be accessed in templates
- `import Ecto.Query` in seeds and query modules
- `validate_number/2` does not support `:allow_nil` — validations skip nil by default
- Fields set programmatically (e.g., `user_id`) must not be in `cast` — set them explicitly
- Use `generators: [timestamp_type: :utc_datetime]` (already configured)

### Templates (HEEx)

- Always use `~H` sigils or `.html.heex` files — never `~E`
- Use `<.form for={@form}>` with `to_form/2` — never pass changesets to templates
- Use `<.input field={@form[:field]}>` from CoreComponents for form inputs
- Use `{...}` for interpolation in attributes, `{@assign}` in tag bodies
- Use `<%= ... %>` only for block constructs (if, for, cond, case)
- Use `<%!-- comment --%>` for HEEx comments
- Add unique DOM IDs to key elements (forms, buttons, containers)
- Use class lists: `class={["base-class", @flag && "conditional-class"]}`
- No `<% Enum.each %>` — use `:for={item <- @collection}` or `<%= for ... do %>`
- No inline `<script>` tags — put JS in `assets/js/`

### LiveView

- Use streams for collections — never assign raw lists
- Use `<.link navigate={...}>` and `<.link patch={...}>` — no `live_redirect`/`live_patch`
- Use `push_navigate/2` and `push_patch/2` in LiveView code
- Begin templates with `<Layouts.app flash={@flash}>` (Layouts is aliased in `tales_life_2_web.ex`)
- Pass `current_scope` to `<Layouts.app>` when in authenticated routes

### CSS & JS

- Tailwind v4 — no `tailwind.config.js` needed; config is in `assets/css/app.css`
- Write custom Tailwind classes — do NOT use daisyUI component classes
- Never use `@apply` in CSS
- Use `<.icon name="hero-icon-name">` for Heroicons — no Heroicons modules
- Only `app.js` and `app.css` bundles exist — import vendor deps into these files
- No external `<script src>` or `<link href>` in layouts

### Testing

- Use `Phoenix.LiveViewTest` and `LazyHTML` for assertions
- Test element presence with `has_element?/2` — never match raw HTML strings
- Reference DOM IDs from templates in tests
- Debug selectors with `LazyHTML.from_fragment/1` and `LazyHTML.filter/2`
