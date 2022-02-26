defmodule Support.Testing.AddReservation do
  use Blunt.Command
  use Blunt.Command.EventDerivation
  field :id, :binary_id

  derive_event ReservationAdded do
    field :person_id, :binary_id
  end
end
