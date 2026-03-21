defmodule AdminKit.FieldTypes.JsonViewer do
  @moduledoc "JSON field type. Formatted display in show; textarea in form."
  @behaviour AdminKit.FieldType
  use Phoenix.Component

  @impl true
  def render_index(nil, _field) do
    assigns = %{}
    ~H|<span class="ak-text-muted">—</span>|
  end

  def render_index(value, _field) when is_map(value) or is_list(value) do
    assigns = %{}
    ~H|<code class="ak-code">{...}</code>|
  end

  def render_index(value, _field) do
    assigns = %{value: to_string(value)}
    ~H|<code class="ak-code"><%= @value %></code>|
  end

  @impl true
  def render_show(nil, _field) do
    assigns = %{}
    ~H|<span class="ak-text-muted">—</span>|
  end

  def render_show(value, _field) do
    formatted = Jason.encode!(value, pretty: true)
    assigns = %{value: formatted}
    ~H|<pre class="ak-code ak-json-viewer"><%= @value %></pre>|
  end

  @impl true
  def render_form(form, field, _opts) do
    current = Phoenix.HTML.Form.input_value(form, field.name)

    text_value =
      case current do
        val when is_map(val) or is_list(val) -> Jason.encode!(val, pretty: true)
        val -> to_string(val || "")
      end

    assigns = %{form: form, field: field.name, value: text_value}

    ~H"""
    <textarea name={Phoenix.HTML.Form.input_name(@form, @field)} rows="10" class="ak-input ak-textarea ak-code"><%= @value %></textarea>
    """
  end
end
