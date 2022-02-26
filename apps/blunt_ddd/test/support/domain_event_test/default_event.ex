defmodule Support.DomainEventTest.DefaultEvent do
  use Blunt.DomainEvent
  field(:user, :string)
end
