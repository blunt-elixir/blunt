defmodule BluntData.MixProject do
  use Mix.Project

  def project do
    [
      app: :blunt_data,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
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
      {:ecto, "~> 3.7"},
      # Optional deps.
      {:faker, "~> 0.17.0", optional: true},
      {:ex_machina, "~> 2.7", optional: true},

      # For testing
      {:elixir_uuid, "~> 1.6", only: [:dev, :test], override: true, hex: :uuid_utils}
    ]
  end
end
