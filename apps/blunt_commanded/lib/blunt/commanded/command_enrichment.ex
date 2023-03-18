defmodule Blunt.Commanded.CommandEnrichment do
  alias Blunt.DispatchStrategy.PipelineResolver

  @behaviour PipelineResolver

  @callback enrich(command :: struct(), context :: Blunt.DispatchContext.t()) :: struct()

  @impl PipelineResolver
  def resolve(:command, message_module) do
    handler = message_module |> Module.concat(:Enrichment) |> to_string()
    {:ok, String.to_existing_atom(handler)}
  rescue
    _ -> {:ok, Blunt.Commanded.CommandEnrichment.Default}
  end

  def resolve(_message_type, _message_module) do
    {:ok, Blunt.Commanded.CommandEnrichment.Default}
  end
end
