defmodule AdminKit.DataCase do
  @moduledoc "Test case for tests that require database access."
  use ExUnit.CaseTemplate

  using do
    quote do
      alias AdminKit.TestApp.Repo
      import AdminKit.TestApp.Fixtures
    end
  end

  setup tags do
    pid = Ecto.Adapters.SQL.Sandbox.start_owner!(AdminKit.TestApp.Repo, shared: not tags[:async])
    on_exit(fn -> Ecto.Adapters.SQL.Sandbox.stop_owner(pid) end)
    :ok
  end
end
