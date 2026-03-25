defmodule AdminKit.FieldTypes.MultiSelect do
  @moduledoc "Multi-select field type. Tag list in index; checkbox group in form."
  @behaviour AdminKit.FieldType
  use Phoenix.Component

  @impl true
  def render_index(nil, _field) do
    assigns = %{}
    ~H|<span class="ak-text-muted">—</span>|
  end

  def render_index(values, _field) when is_list(values) do
    assigns = %{values: Enum.map(values, &humanize/1)}

    ~H"""
    <div class="ak-tag-list">
      <%= for val <- @values do %>
        <span class="ak-badge"><%= val %></span>
      <% end %>
    </div>
    """
  end

  def render_index(value, field), do: render_index(List.wrap(value), field)

  @impl true
  def render_show(value, field), do: render_index(value, field)

  @impl true
  def render_form(form, field, _opts) do
    choices = Keyword.get(field.opts, :choices, [])
    current = List.wrap(Phoenix.HTML.Form.input_value(form, field.name))
    current_strings = Enum.map(current, &to_string/1)
    assigns = %{form: form, field: field.name, choices: choices, current: current_strings}

    ~H"""
    <div class="ak-checkbox-group">
      <%= for choice <- @choices do %>
        <label class="ak-checkbox-label">
          <input
            type="checkbox"
            name={Phoenix.HTML.Form.input_name(@form, @field) <> "[]"}
            value={choice}
            checked={to_string(choice) in @current}
            class="ak-checkbox"
          />
          <%= humanize(choice) %>
        </label>
      <% end %>
    </div>
    """
  end

  defp humanize(value) do
    value |> to_string() |> String.replace("_", " ") |> String.capitalize()
  end
end
