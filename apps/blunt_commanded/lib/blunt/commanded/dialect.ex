defmodule Blunt.Commanded.Dialect do
  @moduledoc false
  @behaviour Blunt.Dialect

  def setup(opts) do
    commanded_app = Keyword.fetch!(opts, :commanded_app)

    %Blunt.Dialect{
      dispatch_strategy: Blunt.Commanded.DispatchStrategy,
      pipeline_resolver: Blunt.Commanded.CommandEnrichment,
      opts: [
        commanded_app: commanded_application
      ]
    }
  end

  def commanded_app!(%Blunt.Dialect{opts: opts}) do
    Keyword.fetch!(opts, :commanded_app)
  end
end
