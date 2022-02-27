defmodule Support.StateTest.Protocol.ReservationAdded do
  use Blunt.Message
  field :person_id, :binary_id
  field :reservation_id, :binary_id
end
