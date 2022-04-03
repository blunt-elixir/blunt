defmodule Support.ContextTest.ZeroFieldQuery do
  use Blunt.Query
end

defmodule Support.ContextTest.ZeroFieldQueryHandler do
  use Blunt.QueryHandler

  alias Blunt.Repo
  alias Support.ContextTest.ReadModel.Person

  @impl true
  def create_query(_filters, _context), do: Person

  @impl true
  def handle_dispatch(query, _context, opts),
    do: Repo.all(query, opts)
end
