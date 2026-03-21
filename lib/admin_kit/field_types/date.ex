defmodule AdminKit.FieldTypes.Date do
  @moduledoc "Date-only field type."
  @behaviour AdminKit.FieldType
  use Phoenix.Component

  @impl true
  def render_index(nil, _field) do
    assigns = %{}
    ~H|<span class="ak-text-muted">—</span>|
  end

  def render_index(value, _field) do
    assigns = %{formatted: Calendar.strftime(value, "%b %d, %Y")}
    ~H|<span><%= @formatted %></span>|
  end

  @impl true
  def render_show(nil, _field) do
    assigns = %{}
    ~H|<span class="ak-text-muted">—</span>|
  end

  def render_show(value, _field) do
    assigns = %{formatted: Calendar.strftime(value, "%B %d, %Y")}
    ~H|<span><%= @formatted %></span>|
  end

  @impl true
  def render_form(form, field, _opts) do
    assigns = %{form: form, field: field.name}

    ~H"""
    <input type="date" name={Phoenix.HTML.Form.input_name(@form, @field)} value={Phoenix.HTML.Form.input_value(@form, @field)} class="ak-input" />
    """
  end
end
