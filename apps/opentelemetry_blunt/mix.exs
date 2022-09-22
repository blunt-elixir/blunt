defmodule OpentelemetryBlunt.MixProject do
  use Mix.Project

  def project do
    [
      app: :opentelemetry_blunt,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:opentelemetry_api, "~> 1.1"},
      {:opentelemetry, "~> 1.0", only: :test},
      {:opentelemetry_process_propagator, "~> 0.1"},
      {:opentelemetry_telemetry, "~> 1.0"},
      {:blunt, in_umbrella: true}
    ]
  end
end
