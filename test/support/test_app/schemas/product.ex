defmodule AdminKit.TestApp.Product do
  use Ecto.Schema
  import Ecto.Changeset

  schema "products" do
    field :title, :string
    field :description, :string
    field :price, :integer
    field :active, :boolean, default: true
    timestamps()
  end

  def changeset(product \\ %__MODULE__{}, attrs) do
    product
    |> cast(attrs, [:title, :description, :price, :active])
    |> validate_required([:title, :price])
    |> validate_number(:price, greater_than: 0)
  end
end
