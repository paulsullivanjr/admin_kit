defmodule AdminKit.FieldTypes.Boolean do
  @moduledoc "Boolean field type. Checkmark / X badge display."
  @behaviour AdminKit.FieldType
  use Phoenix.Component

  @impl true
  def render_index(true, _field) do
    assigns = %{}
    ~H|<span class="ak-badge ak-badge-success">Yes</span>|
  end

  def render_index(false, _field) do
    assigns = %{}
    ~H|<span class="ak-badge ak-badge-danger">No</span>|
  end

  def render_index(nil, _field) do
    assigns = %{}
    ~H|<span class="ak-text-muted">—</span>|
  end

  @impl true
  def render_show(value, field), do: render_index(value, field)

  @impl true
  def render_form(form, field, _opts) do
    assigns = %{form: form, field: field.name}

    ~H"""
    <label class="ak-checkbox-label">
      <input type="hidden" name={Phoenix.HTML.Form.input_name(@form, @field)} value="false" />
      <input type="checkbox" name={Phoenix.HTML.Form.input_name(@form, @field)} value="true" checked={Phoenix.HTML.Form.input_value(@form, @field) == true} class="ak-checkbox" />
    </label>
    """
  end
end
