defmodule BluntAbsintheRelay.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      version: @version,
      app: :blunt_absinthe_relay,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      source_url: "https://github.com/blunt-elixir/blunt_absinthe_relay",
      package: [
        description: "Absinthe Relay macros for `blunt` commands and queries",
        licenses: ["MIT"],
        links: %{"GitHub" => "https://github.com/blunt-elixir/blunt_absinthe_relay"}
      ],
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [extra_applications: [:logger]]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:absinthe, "~> 1.7", override: true},
      {:absinthe_relay, "~> 1.5"},

      # Blunt
      # {:blunt, path: "../blunt"},
      # {:blunt_absinthe, path: "../blunt_absinthe"},
      {:blunt, "~> 0.1"},
      {:blunt_absinthe, "~> 0.1"},

      # For testing
      {:etso, "~> 0.1.6", only: [:test]},
      {:faker, "~> 0.17.0", optional: true, only: [:test]},
      {:ex_machina, "~> 2.7", optional: true, only: [:test]},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
      {:elixir_uuid, "~> 1.6", only: [:dev, :test], override: true, hex: :uuid_utils},

      # generate docs
      {:ex_doc, "~> 0.28", only: :dev, runtime: false}
    ]
  end
end
