defmodule Support.Testing.GetPerson do
  use Blunt.Query

  field :id, :binary_id, required: true

  binding :person, Support.Testing.ReadModel.Person
end

defmodule Support.Testing.GetPersonPipeline do
  use Blunt.QueryPipeline

  alias Blunt.Query
  alias Support.Testing.ReadModel.Person

  @impl true
  def create_query(filters, _context) do
    query = from(p in Person, as: :person)

    Enum.reduce(filters, query, fn
      {:id, id}, query -> from([person: p] in query, where: p.id == ^id)
      _other, query -> query
    end)
  end

  @impl true
  def handle_dispatch(_query, context, _opts) do
    %{id: id} = Query.filters(context)
    %{id: id, name: "chris"}
  end
end
