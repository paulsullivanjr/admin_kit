defmodule AdminKit.TestApp.Accounts do
  alias AdminKit.TestApp.{Repo, User}
  import Ecto.Query

  def list_users(_params \\ %{}) do
    User |> order_by(desc: :inserted_at) |> Repo.all()
  end

  def get_user!(id), do: Repo.get!(User, id)

  def create_user(attrs) do
    %User{} |> User.changeset(attrs) |> Repo.insert()
  end

  def update_user(user, attrs) do
    user |> User.changeset(attrs) |> Repo.update()
  end

  def delete_user(user), do: Repo.delete(user)

  def change_user(user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  def confirm_user(user) do
    user |> Ecto.Changeset.change(confirmed_at: NaiveDateTime.utc_now()) |> Repo.update()
  end
end
