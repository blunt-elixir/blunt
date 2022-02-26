defmodule CommandToTestDerivation do
  use Blunt.Command

  field :id, :binary_id
  field :name, :string
end

defmodule Support.DomainEventTest.EventDerivedFromCommand do
  use Blunt.DomainEvent, derive_from: CommandToTestDerivation
end

defmodule Support.DomainEventTest.EventDerivedFromCommandWithDrop do
  use Blunt.DomainEvent, derive_from: CommandToTestDerivation, drop: :name
end
