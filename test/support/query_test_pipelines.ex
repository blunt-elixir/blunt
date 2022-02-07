defmodule Cqrs.QueryTest.Protocol.GetPersonPipeline do
  use Cqrs.QueryPipeline

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

defmodule Cqrs.QueryTest.Protocol.CreatePersonPipeline do
  use Cqrs.CommandPipeline

  alias Cqrs.Repo
  alias Cqrs.QueryTest.ReadModel.Person
  alias Cqrs.QueryTest.Protocol.CreatePerson

  @impl true
  def handle_dispatch(%CreatePerson{id: id, name: name}, _context) do
    %{id: id, name: name}
    |> Person.changeset()
    |> Repo.insert()
  end
end
