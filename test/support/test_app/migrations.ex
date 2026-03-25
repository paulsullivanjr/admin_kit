defmodule AdminKit.TestApp.Migrations do
  use Ecto.Migration

  def change do
    create table(:users) do
      add(:name, :string, null: false)
      add(:email, :string, null: false)
      add(:role, :string, default: "viewer")
      add(:confirmed_at, :naive_datetime)
      timestamps()
    end

    create(unique_index(:users, [:email]))

    create table(:products) do
      add(:title, :string, null: false)
      add(:description, :text)
      add(:price, :integer, null: false)
      add(:active, :boolean, default: true)
      timestamps()
    end
  end
end
