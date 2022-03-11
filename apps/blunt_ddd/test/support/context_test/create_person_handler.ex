defmodule Support.ContextTest.CreatePersonHandler do
  use Blunt.CommandHandler

  alias Blunt.Repo
  alias Support.ContextTest.ReadModel.Person

  @impl true
  def handle_dispatch(%{id: id, name: name}, _context) do
    %{id: id, name: name}
    |> Person.changeset()
    |> Repo.insert()
  end
end
