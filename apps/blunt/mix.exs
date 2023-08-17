defmodule Blunt.MixProject do
  use Mix.Project

  @version String.trim(File.read!("__VERSION"))

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
        organization: "oforce_dev",
        description: "CQRS for Elixir",
        licenses: ["MIT"],
        files: ~w(lib .formatter.exs mix.exs README* __VERSION),
        links: %{"GitHub" => "https://github.com/blunt-elixir/blunt"}
      ],
      consolidate_protocols: Mix.env() != :test,
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
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    env = System.get_env("MIX_LOCAL") || Mix.env()

    blunt(env) ++
      [
        {:jason, "~> 1.3"},
        {:ecto, "~> 3.9"},
        {:decimal, "~> 1.6 or ~> 2.0"},

        # Telemetry
        {:telemetry, "~> 0.4 or ~> 1.0"},
        {:telemetry_registry, "~> 0.2 or ~> 0.3"},

        # Optional deps.
        {:faker, "~> 0.17.0", optional: true},
        {:ex_machina, "~> 2.7", optional: true},

        # For testing
        {:etso, "~> 0.1.6", only: [:test]},
        {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
        {:uniq, "~> 0.1"},
        {:elixir_uuid, "~> 0.1", hex: :uniq_compat},

        # generate docs
        {:ex_doc, "~> 0.28", only: :dev, runtime: false}
      ]
  end

  defp blunt(:prod), do: [{:blunt_data, "~> #{@version}", organization: "oforce_dev"}]

  defp blunt(_env) do
    case System.get_env("HEX_API_KEY") do
      nil -> [{:blunt_data, in_umbrella: true, organization: "oforce_dev"}]
      _hex -> [{:blunt_data, "~> #{@version}", organization: "oforce_dev"}]
    end
  end
end
