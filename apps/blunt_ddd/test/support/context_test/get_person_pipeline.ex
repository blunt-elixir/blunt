defmodule Support.ContextTest.GetPersonPipeline do
  use Blunt.QueryPipeline

  alias Blunt.Repo
  alias Support.ContextTest.ReadModel.Person

  @impl true
  def create_query(filters, _context) do
    query = from p in Person, as: :person

    Enum.reduce(filters, query, fn
      {:id, id}, query -> from [person: p] in query, where: p.id == ^id
    end)
  end

  @impl true
  def handle_dispatch(query, _context, opts),
    do: Repo.one(query, opts)
end
