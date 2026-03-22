defmodule AdminKit.TestApp.Fixtures do
  alias AdminKit.TestApp.{Repo, User, Product}

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      %User{}
      |> User.changeset(
        Map.merge(
          %{
            name: "User #{System.unique_integer([:positive])}",
            email: "user#{System.unique_integer([:positive])}@example.com",
            role: :viewer
          },
          attrs
        )
      )
      |> Repo.insert()

    user
  end

  def product_fixture(attrs \\ %{}) do
    {:ok, product} =
      %Product{}
      |> Product.changeset(
        Map.merge(
          %{
            title: "Product #{System.unique_integer([:positive])}",
            description: "A test product",
            price: 1999,
            active: true
          },
          attrs
        )
      )
      |> Repo.insert()

    product
  end
end
