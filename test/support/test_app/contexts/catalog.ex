defmodule AdminKit.TestApp.Catalog do
  alias AdminKit.TestApp.{Repo, Product}
  import Ecto.Query

  def list_products(_params \\ %{}) do
    Product |> order_by(desc: :inserted_at) |> Repo.all()
  end

  def get_product!(id), do: Repo.get!(Product, id)

  def create_product(attrs) do
    %Product{} |> Product.changeset(attrs) |> Repo.insert()
  end

  def update_product(product, attrs) do
    product |> Product.changeset(attrs) |> Repo.update()
  end

  def delete_product(product), do: Repo.delete(product)

  def change_product(product, attrs \\ %{}) do
    Product.changeset(product, attrs)
  end
end
