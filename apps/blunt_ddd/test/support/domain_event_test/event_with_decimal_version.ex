defmodule Support.DomainEventTest.EventWithDecimalVersion do
  use Blunt.DomainEvent

  @version 2

  field(:user, :string)
end
