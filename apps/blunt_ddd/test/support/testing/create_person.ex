defmodule Support.Testing.CreatePerson do
  use Blunt.Command
  use Blunt.Command.EventDerivation

  field :id, :binary_id
  field :name, :string

  derive_event PersonCreated
end

defmodule Support.Testing.CreatePersonHandler do
  use Blunt.CommandHandler

  @impl true
  def handle_dispatch(command, _context) do
    {:dispatched, command}
  end
end
