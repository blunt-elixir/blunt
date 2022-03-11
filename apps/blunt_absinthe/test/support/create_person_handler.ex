defmodule Blunt.Absinthe.Test.CreatePersonHandler do
  use Blunt.CommandHandler

  alias Blunt.Repo
  alias Blunt.Absinthe.Test.ReadModel.Person

  @impl true
  def handle_dispatch(command, _context) do
    command
    |> Map.from_struct()
    |> Person.changeset()
    |> Repo.insert()
  end
end
