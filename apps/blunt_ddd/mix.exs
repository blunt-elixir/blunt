defmodule CqrsToolsDdd.MixProject do
  use Mix.Project

  @version String.trim(File.read!("__VERSION"))

  def project do
    [
      version: @version,
      app: :blunt_ddd,
      elixir: "~> 1.12",
      #
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      #
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: [
        organization: "oforce_dev",
        description: "DDD semantics for blunt",
        licenses: ["MIT"],
        files: ~w(lib .formatter.exs mix.exs README* __VERSION),
        links: %{"GitHub" => "https://github.com/blunt-elixir/blunt_ddd"}
      ],
      source_url: "https://github.com/blunt-elixir/blunt_ddd",
      elixirc_paths: elixirc_paths(Mix.env())
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
        # For testing
        {:etso, "~> 0.1.6", only: [:test]},
        {:faker, "~> 0.17.0", optional: true, only: [:test]},
        {:ex_machina, "~> 2.7", optional: true, only: [:test]},
        {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},

        # generate docs
        {:ex_doc, "~> 0.28", only: :dev, runtime: false}
      ]
  end

  defp blunt(:prod) do
    [
      {:blunt, "~> 0.1"},
      {:blunt_data, "~> 0.1"}
    ]
  end

  defp blunt(_env) do
    case System.get_env("HEX_API_KEY") do
      nil ->
        [
          {:blunt, in_umbrella: true},
          {:blunt_data, in_umbrella: true}
        ]

      _hex ->
        [
          {:blunt, "~> #{@version}", organization: "oforce_dev"},
          {:blunt_data, "~> #{@version}", organization: "oforce_dev"}
        ]
    end
  end
end
