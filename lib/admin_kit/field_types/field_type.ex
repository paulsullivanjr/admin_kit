defmodule AdminKit.FieldType do
  @moduledoc """
  Behaviour for custom and built-in field type renderers.

  Each field type implements three rendering callbacks:
  - `render_index/2` — compact display in a table cell
  - `render_show/2` — full display on the show page
  - `render_form/3` — form input widget

  ## Registering a custom field type

      # In your app's Application.start/2 or a config module:
      AdminKit.register_field_type(:color_picker, MyApp.Admin.ColorPickerField)
  """

  @callback render_index(value :: any(), field :: AdminKit.Field.t()) :: Phoenix.HTML.safe()
  @callback render_show(value :: any(), field :: AdminKit.Field.t()) :: Phoenix.HTML.safe()
  @callback render_form(
              form :: Phoenix.HTML.Form.t(),
              field :: AdminKit.Field.t(),
              opts :: keyword()
            ) :: Phoenix.HTML.safe()
end
