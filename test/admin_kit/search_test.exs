defmodule AdminKit.SearchTest do
  use ExUnit.Case, async: true

  alias AdminKit.Search
  import Ecto.Query

  describe "apply_search/3" do
    test "returns query unchanged for nil search" do
      query = from(u in "users")
      assert Search.apply_search(query, nil, [:name]) == query
    end

    test "returns query unchanged for empty search" do
      query = from(u in "users")
      assert Search.apply_search(query, "", [:name]) == query
    end

    test "adds where clause for search term" do
      query = from(u in "users")
      result = Search.apply_search(query, "test", [:name, :email])
      # Verify the query was modified (has where clause)
      refute result == query
    end
  end

  describe "apply_sort/3" do
    test "adds order_by clause" do
      query = from(u in "users")
      result = Search.apply_sort(query, :name, :asc)
      refute result == query
    end
  end

  describe "apply_scope/2" do
    test "returns query unchanged for nil scope" do
      query = from(u in "users")
      assert Search.apply_scope(query, nil) == query
    end

    test "applies scope filter function" do
      query = from(u in "users")
      scope = %AdminKit.Scope{name: :test, filter: fn q -> where(q, [u], u.id > 5) end}
      result = Search.apply_scope(query, scope)
      refute result == query
    end
  end
end
