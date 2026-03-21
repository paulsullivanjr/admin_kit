defmodule AdminKit.FieldTypes.String do
  @moduledoc "Plain text field type. Truncates at 80 chars in index view."
  @behaviour AdminKit.FieldType
  use Phoenix.Component

  @impl true
  def render_index(nil, _field) do
    assigns = %{}
    ~H|<span class="ak-text-muted">—</span>|
  end

  def render_index(value, _field) do
    full = to_string(value)
    truncated = String.slice(full, 0, 80)
    assigns = %{value: truncated, full: full, truncated?: String.length(full) > 80}

    ~H"""
    <span title={if @truncated?, do: @full}><%= @value %><%= if @truncated?, do: "..." %></span>
    """
  end

  @impl true
  def render_show(nil, _field) do
    assigns = %{}
    ~H|<span class="ak-text-muted">—</span>|
  end

  def render_show(value, _field) do
    assigns = %{value: to_string(value)}
    ~H|<span><%= @value %></span>|
  end

  @impl true
  def render_form(form, field, _opts) do
    assigns = %{form: form, field: field.name}

    ~H"""
    <input type="text" name={Phoenix.HTML.Form.input_name(@form, @field)} value={Phoenix.HTML.Form.input_value(@form, @field)} class="ak-input" />
    """
  end
end
