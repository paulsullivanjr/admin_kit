defmodule AdminKit.FieldTypes.Select do
  @moduledoc "Select field type. Colored badge in index; `<select>` in form."
  @behaviour AdminKit.FieldType
  use Phoenix.Component

  @impl true
  def render_index(nil, _field) do
    assigns = %{}
    ~H|<span class="ak-text-muted">—</span>|
  end

  def render_index(value, _field) do
    assigns = %{value: humanize(value)}
    ~H|<span class="ak-badge"><%= @value %></span>|
  end

  @impl true
  def render_show(value, field), do: render_index(value, field)

  @impl true
  def render_form(form, field, _opts) do
    choices = Keyword.get(field.opts, :choices, [])
    options = Enum.map(choices, fn c -> {humanize(c), c} end)
    assigns = %{form: form, field: field.name, options: options}

    ~H"""
    <select name={Phoenix.HTML.Form.input_name(@form, @field)} class="ak-input">
      <option value="">Select...</option>
      <%= for {label, val} <- @options do %>
        <option value={val} selected={to_string(Phoenix.HTML.Form.input_value(@form, @field)) == to_string(val)}><%= label %></option>
      <% end %>
    </select>
    """
  end

  defp humanize(value) do
    value |> to_string() |> String.replace("_", " ") |> String.capitalize()
  end
end
