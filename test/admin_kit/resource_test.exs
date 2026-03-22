defmodule AdminKit.ResourceTest do
  use ExUnit.Case, async: true

  alias AdminKit.ResourceConfig

  describe "DSL compilation" do
    test "compiles valid config from admin module" do
      resources = AdminKit.TestApp.Admin.__resources__()
      assert length(resources) == 2

      user_config = Enum.find(resources, &(&1.schema == AdminKit.TestApp.User))
      assert user_config.context == AdminKit.TestApp.Accounts
      assert user_config.singular_name == "user"
      assert user_config.plural_name == "users"
      assert user_config.per_page == 25
    end

    test "index_fields returns fields in declared order" do
      [user_config | _] = AdminKit.TestApp.Admin.__resources__()
      user_config = if user_config.schema == AdminKit.TestApp.User, do: user_config, else: Enum.at(AdminKit.TestApp.Admin.__resources__(), 1)

      index = ResourceConfig.index_fields(user_config)
      names = Enum.map(index, & &1.name)
      assert names == [:name, :email, :role, :inserted_at]
    end

    test "form_fields returns fields in declared order" do
      resources = AdminKit.TestApp.Admin.__resources__()
      user_config = Enum.find(resources, &(&1.schema == AdminKit.TestApp.User))

      form = ResourceConfig.form_fields(user_config)
      names = Enum.map(form, & &1.name)
      assert names == [:name, :email, :role]
    end

    test "infers field types from Ecto schema" do
      resources = AdminKit.TestApp.Admin.__resources__()
      user_config = Enum.find(resources, &(&1.schema == AdminKit.TestApp.User))

      name_field = Enum.find(user_config.fields, &(&1.name == :name))
      assert name_field.type == :string

      email_field = Enum.find(user_config.fields, &(&1.name == :email))
      assert email_field.type == :string
    end

    test "respects explicit field type override" do
      resources = AdminKit.TestApp.Admin.__resources__()
      user_config = Enum.find(resources, &(&1.schema == AdminKit.TestApp.User))

      role_field = Enum.find(user_config.fields, &(&1.name == :role))
      assert role_field.type == :select
    end

    test "scopes are compiled correctly" do
      resources = AdminKit.TestApp.Admin.__resources__()
      user_config = Enum.find(resources, &(&1.schema == AdminKit.TestApp.User))

      assert length(user_config.scopes) == 2
      default = ResourceConfig.default_scope(user_config)
      assert default.name == :all
    end

    test "default_scope returns nil when no default set" do
      config = %ResourceConfig{scopes: [%AdminKit.Scope{name: :active, default: false}]}
      assert ResourceConfig.default_scope(config) == nil
    end

    test "actions are compiled correctly" do
      resources = AdminKit.TestApp.Admin.__resources__()
      user_config = Enum.find(resources, &(&1.schema == AdminKit.TestApp.User))

      assert length(user_config.actions) == 1
      action = hd(user_config.actions)
      assert action.name == :confirm
      assert action.label == "Confirm"
      assert is_function(action.handler, 1)
    end

    test "searchable_fields are set" do
      resources = AdminKit.TestApp.Admin.__resources__()
      user_config = Enum.find(resources, &(&1.schema == AdminKit.TestApp.User))

      assert user_config.searchable_fields == [:name, :email]
    end
  end
end
