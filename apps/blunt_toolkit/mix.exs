defmodule CommandedToolkit.MixProject do
  use Mix.Project

  @version "0.1.0-rc1"

  def project do
    [
      app: :blunt_toolkit,
      version: @version,
      elixir: "~> 1.12",
      #
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      #

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
    env = System.get_env("MIX_LOCAL") || Mix.env()

    blunt(env) ++
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

  defp blunt(:prod) do
    [
      {:blunt, "~> 0.1"},
      {:blunt_data, "~> 0.1"},
      {:blunt_ddd, "~> 0.1"},
      {:blunt_absinthe, "~> 0.1"}
    ]
  end

  defp blunt(_env) do
    [
      {:blunt, in_umbrella: true},
      {:blunt_data, in_umbrella: true},
      {:blunt_ddd, in_umbrella: true},
      {:blunt_absinthe, in_umbrella: true}
    ]
  end

  def aliases do
    [
      view_state: "blunt.inspect.aggregate"
    ]
  end
end
