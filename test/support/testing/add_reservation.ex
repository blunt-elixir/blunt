defmodule Support.Testing.AddReservation do
  @moduledoc """
  Adds a reservation to the system.
  """
  use Blunt.Command
  field :id, :binary_id, desc: "The identity of the reservation"
end
