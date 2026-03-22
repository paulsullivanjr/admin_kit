defmodule AdminKit.FieldTest do
  use ExUnit.Case, async: true

  alias AdminKit.Field

  describe "label/1" do
    test "returns custom label when set" do
      field = %Field{name: :email, type: :string, label: "Email Address"}
      assert Field.label(field) == "Email Address"
    end

    test "generates label from field name when not set" do
      field = %Field{name: :first_name, type: :string}
      assert Field.label(field) == "First name"
    end

    test "replaces underscores with spaces" do
      field = %Field{name: :created_at, type: :datetime}
      assert Field.label(field) == "Created at"
    end
  end
end
