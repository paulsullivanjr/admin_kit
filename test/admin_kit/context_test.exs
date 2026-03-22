defmodule AdminKit.ContextTest do
  use AdminKit.DataCase

  alias AdminKit.Context

  setup do
    resources = AdminKit.TestApp.Admin.__resources__()
    user_config = Enum.find(resources, &(&1.schema == AdminKit.TestApp.User))
    %{config: user_config}
  end

  describe "list/2" do
    test "lists records via context", %{config: config} do
      user_fixture(%{name: "Alice", email: "alice@example.com"})
      user_fixture(%{name: "Bob", email: "bob@example.com"})

      result = Context.list(config, %{})
      assert length(result) == 2
    end
  end

  describe "get/2" do
    test "gets a record by id", %{config: config} do
      user = user_fixture(%{name: "Alice", email: "alice@test.com"})
      result = Context.get(config, user.id)
      assert result.id == user.id
      assert result.name == "Alice"
    end
  end

  describe "create/2" do
    test "creates a record with valid attrs", %{config: config} do
      assert {:ok, user} = Context.create(config, %{name: "New User", email: "new@test.com", role: :viewer})
      assert user.name == "New User"
    end

    test "returns error changeset with invalid attrs", %{config: config} do
      assert {:error, %Ecto.Changeset{}} = Context.create(config, %{name: "", email: ""})
    end
  end

  describe "update/3" do
    test "updates a record with valid attrs", %{config: config} do
      user = user_fixture(%{name: "Old Name", email: "old@test.com"})
      assert {:ok, updated} = Context.update(config, user, %{name: "New Name"})
      assert updated.name == "New Name"
    end
  end

  describe "delete/2" do
    test "deletes a record", %{config: config} do
      user = user_fixture(%{name: "Delete Me", email: "delete@test.com"})
      assert {:ok, _} = Context.delete(config, user)
      assert_raise Ecto.NoResultsError, fn -> Context.get(config, user.id) end
    end
  end

  describe "change/3" do
    test "returns a changeset", %{config: config} do
      user = user_fixture(%{name: "Test", email: "change@test.com"})
      changeset = Context.change(config, user, %{name: "Updated"})
      assert %Ecto.Changeset{} = changeset
    end
  end
end
