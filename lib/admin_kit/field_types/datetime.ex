defmodule AdminKit.FieldTypes.Datetime do
  @moduledoc "Datetime field type. Formatted display with relative time in index."
  @behaviour AdminKit.FieldType
  use Phoenix.Component

  @impl true
  def render_index(nil, _field) do
    assigns = %{}
    ~H|<span class="ak-text-muted">—</span>|
  end

  def render_index(value, _field) do
    assigns = %{formatted: format_short(value), iso: to_string(value)}
    ~H|<time datetime={@iso} title={@iso}><%= @formatted %></time>|
  end

  @impl true
  def render_show(nil, _field) do
    assigns = %{}
    ~H|<span class="ak-text-muted">—</span>|
  end

  def render_show(value, _field) do
    assigns = %{formatted: format_full(value), iso: to_string(value)}
    ~H|<time datetime={@iso}><%= @formatted %></time>|
  end

  @impl true
  def render_form(form, field, _opts) do
    assigns = %{form: form, field: field.name}

    ~H"""
    <input
      type="datetime-local"
      name={Phoenix.HTML.Form.input_name(@form, @field)}
      value={format_input(Phoenix.HTML.Form.input_value(@form, @field))}
      class="ak-input"
    />
    """
  end

  defp format_short(nil), do: ""
  defp format_short(dt), do: Calendar.strftime(dt, "%b %d, %Y %H:%M")

  defp format_full(nil), do: ""
  defp format_full(dt), do: Calendar.strftime(dt, "%B %d, %Y at %H:%M:%S")

  defp format_input(nil), do: ""

  defp format_input(%NaiveDateTime{} = dt),
    do: Calendar.strftime(dt, "%Y-%m-%dT%H:%M")

  defp format_input(%DateTime{} = dt),
    do: Calendar.strftime(dt, "%Y-%m-%dT%H:%M")

  defp format_input(value), do: to_string(value)
end
