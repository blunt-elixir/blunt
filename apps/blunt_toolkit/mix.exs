defmodule CommandedToolkit.MixProject do
  use Mix.Project

  def project do
    [
      app: :blunt_toolkit,
      version: "0.1.0",
      elixir: "~> 1.12",
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
    blunt(Mix.env()) ++
      [
        {:ratatouille, "~> 0.5"},
        {:commanded, "~> 1.3"},
        {:eventstore, "~> 1.3"},
        {:jason, "~> 1.3"},
        {:elixir_uuid, "~> 1.6", override: true, hex: :uuid_utils},
        {:faker, "~> 0.17.0", only: :test},
        {:ex_machina, "~> 2.7", only: :test}
      ]
  end

  # defp blunt(:prod) do
  #   [
  #     {:blunt, github: "blunt-elixir/blunt", ref: "reorg", sparse: "apps/blunt"},
  #     {:blunt_ddd, github: "blunt-elixir/blunt", ref: "reorg", sparse: "apps/blunt_ddd"}
  #   ]
  # end

  defp blunt(_env) do
    [
      {:blunt, path: "../blunt", override: true},
      {:blunt_ddd, path: "../blunt_ddd"}
    ]
  end

  def aliases do
    [
      view_state: "blunt.inspect.aggregate"
    ]
  end
end
