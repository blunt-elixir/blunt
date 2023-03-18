defmodule BluntCommanded.Test.Protocol.UpdateUser.Enrichment do
  use Blunt.Commanded.CommandEnrichment

  alias Blunt.DispatchContext
  alias BluntCommanded.Test.Protocol.UpdateUser

  @impl true
  def enrich(%UpdateUser{} = command, %DispatchContext{} = _context) do
    %{command | date: DateTime.utc_now()}
  end
end
