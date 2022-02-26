defmodule Support.StateTest.Protocol.ReservationAdded do
  use Blunt.DomainEvent
  field :person_id, :binary_id
  field :reservation_id, :binary_id
end
