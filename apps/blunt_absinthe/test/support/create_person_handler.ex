defmodule Blunt.Absinthe.Test.CreatePersonHandler do
  use Blunt.CommandHandler

  alias Blunt.Repo
  alias Blunt.Absinthe.Test.ReadModel.Person

  @impl true
  def handle_dispatch(command, _context) do
    command
    |> Map.from_struct()
    |> Map.update!(:address, &to_map/1)
    |> Person.changeset()
    |> Repo.insert()
  end

  defp to_map(nil), do: nil
  defp to_map(value), do: Map.from_struct(value)
end
