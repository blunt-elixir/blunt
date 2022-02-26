defmodule Blunt.Absinthe.Relay.Test.ListPeoplePipeline do
  use Blunt.QueryPipeline

  alias Blunt.Absinthe.Relay.Test.Person

  @impl true
  def create_query(filters, _context) do
    query = from p in Person, as: :person, order_by: p.name

    Enum.reduce(filters, query, fn
      {:name, name}, query ->
        from [person: p] in query,
          where: p.name == ^name

      {:gender, gender}, query ->
        from [person: p] in query,
          where: p.gender == ^gender
    end)
  end

  @impl true
  def handle_dispatch(_query, _context, _opts) do
    {:error, :this_should_never_be_called_by_absinthe_relay}
  end
end
