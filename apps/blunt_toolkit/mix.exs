defmodule CommandedToolkit.MixProject do
  use Mix.Project

  def project do
    [
      app: :blunt_toolkit,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      elixirc_paths: elixirc_paths(Mix.env()),
      preferred_cli_env: [
        "blunt.project": :test,
        view_state: :test
      ]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ratatouille, "~> 0.5"},

      # {:blunt, path: "../blunt", override: true},
      # {:blunt_ddd, path: "../blunt_ddd", override: true},
      {:blunt, "~> 0.1"},
      {:blunt_ddd, "~> 0.1"},

      {:commanded, "~> 1.3"},
      {:eventstore, "~> 1.3"},
      {:jason, "~> 1.3"},
      {:elixir_uuid, "~> 1.6", override: true, hex: :uuid_utils},
      {:faker, "~> 0.17.0", only: :test},
      {:ex_machina, "~> 2.7", only: :test}
    ]
  end

  def aliases do
    [
      view_state: "blunt.inspect.aggregate"
    ]
  end
end
