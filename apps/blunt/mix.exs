defmodule Blunt.MixProject do
  use Mix.Project

  @version "0.1.0-rc1"

  def project do
    [
      app: :blunt,
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
      source_url: "https://github.com/blunt-elixir/blunt",
      package: [
        description: "CQRS Tools for Elixir",
        licenses: ["MIT"],
        links: %{"GitHub" => "https://github.com/blunt-elixir/blunt"}
      ],
      dialyzer: [
        plt_add_deps: :apps_direct,
        plt_add_apps: [:faker, :mix]
      ],
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support", "test/shared"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Blunt, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    env = System.get_env("MIX_LOCAL") || Mix.env()

    blunt(env) ++
      [
        {:jason, "~> 1.3"},
        {:ecto, "~> 3.7"},
        {:decimal, "~> 1.6 or ~> 2.0"},

        # Optional deps.
        {:faker, "~> 0.17.0", optional: true},
        {:ex_machina, "~> 2.7", optional: true},

        # For testing
        {:etso, "~> 0.1.6", only: [:test]},
        {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
        {:elixir_uuid, "~> 1.6", only: [:dev, :test], override: true, hex: :uuid_utils},

        # generate docs
        {:ex_doc, "~> 0.28", only: :dev, runtime: false}
      ]
  end

  defp blunt(:prod), do: [{:blunt_data, "~> 0.1"}]
  defp blunt(_env), do: [{:blunt_data, in_umbrella: true}]
end
