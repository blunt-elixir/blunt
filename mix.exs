defmodule Cqrs.MixProject do
  use Mix.Project

  def project do
    [
      app: :cqrs_tools,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      source_url: "https://github.com/elixir-cqrs/cqrs_tools",
      package: [
        description: "CQRS Tools for Elixir",
        licenses: ["MIT"],
        links: %{"GitHub" => "https://github.com/elixir-cqrs/cqrs_tools"}
      ],
      dialyzer: [
        plt_add_deps: :apps_direct,
        plt_add_apps: [:wx],
        plt_ignore_apps: [:mnesia]
      ],
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
    [
      {:jason, "~> 1.3"},
      {:ecto, "~> 3.7"},
      {:decimal, "~> 1.6 or ~> 2.0"},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
      {:elixir_uuid, "~> 1.6", override: true, hex: :uuid_utils}
    ]
  end
end
