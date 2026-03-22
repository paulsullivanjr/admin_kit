defmodule AdminKitTest do
  use ExUnit.Case

  describe "field_type_module/1" do
    test "resolves built-in field types" do
      assert AdminKit.field_type_module(:string) == AdminKit.FieldTypes.String
      assert AdminKit.field_type_module(:integer) == AdminKit.FieldTypes.Integer
      assert AdminKit.field_type_module(:boolean) == AdminKit.FieldTypes.Boolean
      assert AdminKit.field_type_module(:datetime) == AdminKit.FieldTypes.Datetime
      assert AdminKit.field_type_module(:date) == AdminKit.FieldTypes.Date
      assert AdminKit.field_type_module(:select) == AdminKit.FieldTypes.Select
    end

    test "raises for unknown field type" do
      assert_raise KeyError, fn -> AdminKit.field_type_module(:unknown) end
    end

    test "register_field_type allows custom types" do
      defmodule CustomField do
        @behaviour AdminKit.FieldType
        def render_index(_, _), do: "custom"
        def render_show(_, _), do: "custom"
        def render_form(_, _, _), do: "custom"
      end

      AdminKit.register_field_type(:custom, CustomField)
      assert AdminKit.field_type_module(:custom) == CustomField
    end
  end
end
