# AdminKit

DDD-first LiveView admin interface for Phoenix.

AdminKit is a **context-first** admin UI generator. Unlike schema-centric libraries, it delegates all data operations to your Phoenix context modules, respects DDD boundaries, and renders everything through LiveView with zero full-page reloads.

## Why AdminKit?

- **Context-first** — no direct `Repo` access; all CRUD goes through your context modules
- **LiveView-native** — real-time UI with sorting, search, pagination, and actions
- **Policy-aware** — pluggable authorization via the `AdminKit.Policy` behaviour
- **Extensible field types** — 12 built-in types, register your own at runtime
- **Telemetry instrumented** — all operations emit telemetry events for monitoring

## Installation

Add `admin_kit` to your `mix.exs` dependencies:

```elixir
def deps do
  [
    {:admin_kit, "~> 0.1.0"}
  ]
end
```

## Quick Start

### 1. Define an admin module

```elixir
defmodule MyApp.Admin do
  use AdminKit, otp_app: :my_app

  admin_resource MyApp.Accounts.User do
    context MyApp.Accounts
    index_fields [:name, :email, :role, :inserted_at]
    form_fields  [:name, :email, :role]
    field :role, type: :select, choices: [:admin, :editor, :viewer]
    scope :all, default: true
    scope :admins, filter: &MyApp.Scopes.admin_users/1
    searchable_fields [:name, :email]
    per_page 50
  end
end
```

### 2. Add routes

```elixir
# In your router
import AdminKit.Router

scope "/admin" do
  pipe_through [:browser, :require_admin_user]
  live_admin "/", MyApp.Admin
end
```

### 3. Serve static assets

```elixir
# In your endpoint.ex
plug Plug.Static, at: "/admin_kit", from: {:admin_kit, "priv/static"}
```

This generates routes for:

| Route | View |
|-------|------|
| `/admin` | Dashboard |
| `/admin/users` | User index |
| `/admin/users/new` | New user form |
| `/admin/users/:id` | User detail |
| `/admin/users/:id/edit` | Edit user form |

## DSL Reference

Inside an `admin_resource` block:

| Keyword | Description |
|---------|-------------|
| `context Module` | **Required.** The Phoenix context module for CRUD operations |
| `index_fields [:field, ...]` | Fields to display in the index table |
| `form_fields [:field, ...]` | Fields to display in new/edit forms |
| `field :name, opts` | Configure a specific field (type, label, readonly, etc.) |
| `scope :name, opts` | Define a named filter scope |
| `action :name, opts` | Define a custom action (requires `:handler`) |
| `searchable_fields [:field, ...]` | Fields to search with ilike |
| `per_page 25` | Records per page (default: 25) |
| `policy Module` | Authorization policy module |

### Context Convention

AdminKit expects your context to export functions following Phoenix conventions:

```elixir
# For a resource named "user":
list_users(params)      # or list_users()
get_user!(id)
create_user(attrs)
update_user(user, attrs)
delete_user(user)
change_user(user, attrs) # optional, falls back to schema.changeset/2
```

## Field Types

| Type | Atom | Index | Form |
|------|------|-------|------|
| String | `:string` | Truncated text | Text input |
| Integer | `:integer` | Right-aligned | Number input |
| Boolean | `:boolean` | Yes/No badge | Checkbox |
| Datetime | `:datetime` | Formatted date | Datetime-local input |
| Date | `:date` | Formatted date | Date input |
| Select | `:select` | Badge | Select dropdown |
| Multi Select | `:multi_select` | Tag list | Checkbox group |
| Image | `:image` | Thumbnail | File input |
| Rich Text | `:rich_text` | Plain text excerpt | Textarea |
| JSON | `:json_viewer` | `{...}` | Textarea |
| Belongs To | `:belongs_to` | Display name | Select dropdown |
| Has Many | `:has_many` | Count badge | Read-only |

### Custom Field Types

```elixir
defmodule MyApp.Admin.ColorPickerField do
  @behaviour AdminKit.FieldType

  def render_index(value, _field), do: ...
  def render_show(value, _field), do: ...
  def render_form(form, field, _opts), do: ...
end

AdminKit.register_field_type(:color_picker, MyApp.Admin.ColorPickerField)
```

## Authorization

Implement the `AdminKit.Policy` behaviour:

```elixir
defmodule MyApp.Admin.Policy do
  @behaviour AdminKit.Policy

  @impl true
  def can?(%{assigns: %{current_user: user}}, :delete, _resource),
    do: user.role == :super_admin

  def can?(_, _, _), do: true
end
```

Reference it in your resource: `policy MyApp.Admin.Policy`

Use `AdminKit.Policy.AllowAll` for development (allows everything).

## Custom Actions

```elixir
action :confirm, label: "Confirm Email",
  handler: &MyApp.Accounts.confirm_user/1,
  scope: :member,       # :member (per-record) or :collection (bulk)
  confirm: "Are you sure?"
```

## Scopes

```elixir
scope :all, default: true
scope :admins, label: "Admins Only", filter: &MyApp.Scopes.admin_users/1
```

## Telemetry

AdminKit emits telemetry events for all operations:

- `[:admin_kit, :resource, :list, :start/:stop]`
- `[:admin_kit, :resource, :create, :start/:stop]`
- `[:admin_kit, :resource, :update, :start/:stop]`
- `[:admin_kit, :resource, :delete, :start/:stop]`
- `[:admin_kit, :action, :run, :start/:stop]`

## License

MIT License. See [LICENSE](LICENSE) for details.
