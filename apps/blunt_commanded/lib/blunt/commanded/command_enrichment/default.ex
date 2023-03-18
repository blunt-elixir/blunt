defmodule Blunt.Commanded.CommandEnrichment.Default do
  @behaviour Blunt.Commanded.CommandEnrichment

  def enrich(command), do: command
end
