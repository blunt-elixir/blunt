defmodule BluntCommanded.Test.Protocol.CreateUser do
  use Blunt.Command
  use Blunt.Command.EventDerivation

  field :name, :string
  internal_field :id, :binary_id

  @impl true
  def after_validate(command) do
    Map.put(command, :id, UUID.uuid4())
  end

  derive_event UserCreated
end
