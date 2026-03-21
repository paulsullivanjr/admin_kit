defmodule AdminKit.FieldTypes.BelongsTo do
  @moduledoc "Belongs-to association field type. Linked name in index; select in form."
  @behaviour AdminKit.FieldType
  use Phoenix.Component

  @impl true
  def render_index(nil, _field) do
    assigns = %{}
    ~H|<span class="ak-text-muted">—</span>|
  end

  def render_index(value, _field) do
    assigns = %{value: display_name(value)}
    ~H|<span><%= @value %></span>|
  end

  @impl true
  def render_show(nil, _field) do
    assigns = %{}
    ~H|<span class="ak-text-muted">—</span>|
  end

  def render_show(value, _field) do
    assigns = %{value: display_name(value)}
    ~H|<span><%= @value %></span>|
  end

  @impl true
  def render_form(form, field, opts) do
    options = Keyword.get(opts, :options, Keyword.get(field.opts, :options, []))
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

  defp display_name(%{name: name}), do: name
  defp display_name(%{title: title}), do: title
  defp display_name(%{id: id}), do: "##{id}"
  defp display_name(value), do: to_string(value)
end
