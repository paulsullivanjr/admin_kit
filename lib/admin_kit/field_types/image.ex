defmodule AdminKit.FieldTypes.Image do
  @moduledoc "Image field type. Thumbnail in index/show; file input in form."
  @behaviour AdminKit.FieldType
  use Phoenix.Component

  @impl true
  def render_index(nil, _field) do
    assigns = %{}
    ~H|<span class="ak-text-muted">—</span>|
  end

  def render_index(value, _field) do
    assigns = %{src: to_string(value)}
    ~H|<img src={@src} class="ak-thumbnail ak-thumbnail-sm" alt="" />|
  end

  @impl true
  def render_show(nil, _field) do
    assigns = %{}
    ~H|<span class="ak-text-muted">—</span>|
  end

  def render_show(value, _field) do
    assigns = %{src: to_string(value)}
    ~H|<img src={@src} class="ak-thumbnail ak-thumbnail-lg" alt="" />|
  end

  @impl true
  def render_form(form, field, _opts) do
    assigns = %{form: form, field: field.name}

    ~H"""
    <input
      type="file"
      name={Phoenix.HTML.Form.input_name(@form, @field)}
      accept="image/*"
      class="ak-input"
    />
    """
  end
end
