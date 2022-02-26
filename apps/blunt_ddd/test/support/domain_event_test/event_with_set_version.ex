defmodule Support.DomainEventTest.EventWithSetVersion do
  use Blunt.DomainEvent

  @version 2

  field(:user, :string)
end
