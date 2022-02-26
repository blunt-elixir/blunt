defmodule Blunt.Absinthe.Test.CreatePersonPipeline do
  use Blunt.CommandPipeline

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
