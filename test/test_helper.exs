# Start the test repo
{:ok, _} = AdminKit.TestApp.Repo.start_link()

# Run migrations outside sandbox mode
Ecto.Migrator.up(AdminKit.TestApp.Repo, 0, AdminKit.TestApp.Migrations, log: false)

# Set sandbox mode for tests
Ecto.Adapters.SQL.Sandbox.mode(AdminKit.TestApp.Repo, :manual)

# Start endpoint for LiveView tests
{:ok, _} = AdminKit.TestApp.Endpoint.start_link()

ExUnit.start()
