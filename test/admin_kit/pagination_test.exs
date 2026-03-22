defmodule AdminKit.PaginationTest do
  use ExUnit.Case, async: true

  alias AdminKit.Pagination

  describe "build/3" do
    test "builds pagination from params" do
      result = Pagination.build(100, %{"page" => "2"}, 25)
      assert result.page == 2
      assert result.per_page == 25
      assert result.total_count == 100
      assert result.total_pages == 4
    end

    test "defaults to page 1" do
      result = Pagination.build(50, %{}, 25)
      assert result.page == 1
    end

    test "clamps page to total_pages" do
      result = Pagination.build(10, %{"page" => "999"}, 25)
      assert result.page == 1
    end

    test "clamps page to minimum 1" do
      result = Pagination.build(10, %{"page" => "0"}, 25)
      assert result.page == 1
    end

    test "handles zero total count" do
      result = Pagination.build(0, %{}, 25)
      assert result.page == 1
      assert result.total_pages == 1
    end
  end

  describe "has_prev?/1 and has_next?/1" do
    test "has_prev? false on page 1" do
      result = Pagination.build(100, %{"page" => "1"}, 25)
      refute Pagination.has_prev?(result)
    end

    test "has_prev? true on page 2" do
      result = Pagination.build(100, %{"page" => "2"}, 25)
      assert Pagination.has_prev?(result)
    end

    test "has_next? true when not on last page" do
      result = Pagination.build(100, %{"page" => "1"}, 25)
      assert Pagination.has_next?(result)
    end

    test "has_next? false on last page" do
      result = Pagination.build(100, %{"page" => "4"}, 25)
      refute Pagination.has_next?(result)
    end
  end
end
