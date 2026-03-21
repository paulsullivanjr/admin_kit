defmodule AdminKit.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/your_org/admin_kit"

  def project do
    [
      app: :admin_kit,
      version: @version,
      elixir: "~> 1.15",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      # Hex
      description: "DDD-first LiveView admin interface for Phoenix",
      package: package(),
      # Docs
      name: "AdminKit",
      source_url: @source_url,
      docs: docs()
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:phoenix, "~> 1.7"},
      {:phoenix_live_view, "~> 0.20"},
      {:phoenix_html, "~> 4.0"},
      {:ecto, "~> 3.11"},
      {:jason, "~> 1.4"},
      # Dev/test only
      {:ex_doc, "~> 0.31", only: :dev, runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      # Test only
      {:phoenix_ecto, "~> 4.5", only: :test},
      {:ecto_sqlite3, "~> 0.14", only: :test},
      {:floki, ">= 0.30.0", only: :test}
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url},
      files: ~w(lib priv .formatter.exs mix.exs README.md CHANGELOG.md LICENSE)
    ]
  end

  defp docs do
    [
      main: "readme",
      source_ref: "v#{@version}",
      extras: ["README.md", "CHANGELOG.md"],
      groups_for_modules: [
        Core: [AdminKit, AdminKit.Resource, AdminKit.Router],
        LiveViews: [~r/AdminKit\.Live/],
        Components: [~r/AdminKit\.Components/],
        "Field Types": [~r/AdminKit\.FieldTypes/],
        Behaviours: [AdminKit.Policy, AdminKit.FieldType]
      ]
    ]
  end

  defp aliases do
    [
      "test.setup": ["ecto.create --quiet", "ecto.migrate --quiet"],
      quality: ["format --check-formatted", "credo --strict", "dialyzer"]
    ]
  end
end
