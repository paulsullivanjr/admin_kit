defmodule AdminKit.TestApp.Repo do
  use Ecto.Repo,
    otp_app: :admin_kit,
    adapter: Ecto.Adapters.SQLite3
end
