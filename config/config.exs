import Config

# Library ships no runtime config.
# Host apps configure via: config :admin_kit, key: value

if config_env() == :test do
  config :admin_kit, AdminKit.TestApp.Repo,
    database: "test/support/admin_kit_test.db",
    pool: Ecto.Adapters.SQL.Sandbox

  config :admin_kit, ecto_repos: [AdminKit.TestApp.Repo]

  config :admin_kit, AdminKit.TestApp.Endpoint,
    http: [port: 4002],
    server: false,
    secret_key_base: String.duplicate("test_secret_key_base_", 4),
    live_view: [signing_salt: "test_salt"]

  config :phoenix, :json_library, Jason
  config :logger, level: :warning
end
