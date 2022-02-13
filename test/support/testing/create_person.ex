defmodule Support.Testing.CreatePerson do
  use Cqrs.Command

  field :id, :binary_id
  field :name, :string
end

defmodule Support.Testing.CreatePersonPipeline do
  use Cqrs.CommandPipeline

  @impl true
  def handle_dispatch(command, _context) do
    {:dispatched, command}
  end
end
