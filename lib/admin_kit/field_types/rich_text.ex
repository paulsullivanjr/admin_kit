defmodule AdminKit.FieldTypes.RichText do
  @moduledoc "Rich text field type. Sanitized HTML in show; textarea in form."
  @behaviour AdminKit.FieldType
  use Phoenix.Component

  @impl true
  def render_index(nil, _field) do
    assigns = %{}
    ~H|<span class="ak-text-muted">—</span>|
  end

  def render_index(value, _field) do
    plain = strip_tags(value)
    truncated = String.slice(plain, 0, 80)
    assigns = %{value: truncated, truncated?: String.length(plain) > 80}
    ~H|<span><%= @value %><%= if @truncated?, do: "..." %></span>|
  end

  @impl true
  def render_show(nil, _field) do
    assigns = %{}
    ~H|<span class="ak-text-muted">—</span>|
  end

  def render_show(value, _field) do
    assigns = %{value: value}
    ~H|<div class="ak-rich-text"><%= Phoenix.HTML.raw(@value) %></div>|
  end

  @impl true
  def render_form(form, field, _opts) do
    assigns = %{form: form, field: field.name}

    ~H"""
    <textarea name={Phoenix.HTML.Form.input_name(@form, @field)} rows="8" class="ak-input ak-textarea"><%= Phoenix.HTML.Form.input_value(@form, @field) %></textarea>
    """
  end

  defp strip_tags(html) do
    String.replace(to_string(html), ~r/<[^>]*>/, "")
  end
end
