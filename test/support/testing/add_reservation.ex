defmodule Support.Testing.AddReservation do
  use Cqrs.Command
  field :id, :binary_id
end
