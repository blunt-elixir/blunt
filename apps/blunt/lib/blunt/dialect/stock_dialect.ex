defmodule Blunt.Dialect.StockDialect do
  @behaviour Blunt.Dialect

  @impl true
  def setup(_opts) do
    %Blunt.Dialect{
      dispatch_strategy: Blunt.DispatchStrategy.Default,
      pipeline_resolver: Blunt.DispatchStrategy.PipelineResolver.Default
    }
  end
end
