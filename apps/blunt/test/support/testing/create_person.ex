defmodule Support.Testing.CreatePerson do
  use Blunt.Command

  @moduledoc """
  Creates a person.
  """

  field :id, :binary_id
  field :name, :string
end

defmodule Support.Testing.CreatePersonHandler do
  use Blunt.CommandHandler

  @impl true
  def handle_dispatch(command, _context) do
    {:dispatched, command}
  end
end
