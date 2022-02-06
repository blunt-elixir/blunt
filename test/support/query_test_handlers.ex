defmodule Cqrs.QueryTest.Protocol.GetPersonHandler do
  use Cqrs.QueryHandler

  alias Cqrs.Repo
  alias Cqrs.QueryTest.ReadModel.Person

  @impl true
  def create_query(filters, _context) do
    Enum.reduce(filters, Person, fn
      {:id, id}, query -> from q in query, where: q.id == ^id
      {:name, name}, query -> from q in query, where: q.name == ^name
    end)
  end

  @impl true
  def handle_dispatch(query, _context, opts) do
    Repo.one(query, opts)
  end
end

defmodule Cqrs.QueryTest.Protocol.CreatePersonHandler do
  use Cqrs.CommandHandler

  alias Cqrs.Repo
  alias Cqrs.QueryTest.ReadModel.Person

  @impl true
  def handle_dispatch(%{id: id, name: name}, _context) do
    %{id: id, name: name}
    |> Person.changeset()
    |> Repo.insert()
  end
end
