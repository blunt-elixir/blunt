defmodule Cqrs.DomainEventTest.Protocol do
  defmodule DefaultEvent do
    use Cqrs.DomainEvent
    field :user, :string
  end

  defmodule EventWithSetVersion do
    use Cqrs.DomainEvent

    @version 2

    field :user, :string
  end

  defmodule EventWithSetVersionAsDecimal do
    use Cqrs.DomainEvent

    @version 2.3

    field :user, :string
  end
end
