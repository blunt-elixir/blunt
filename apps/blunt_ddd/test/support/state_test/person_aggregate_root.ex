defmodule Support.StateTest.PersonAggregateRoot do
  @behaviour Blunt.AggregateRoot

  use Blunt.Ddd

  alias Support.StateTest.ReservationEntity
  alias Support.StateTest.Protocol.{PersonCreated, ReservationAdded}

  defstate do
    field :id, :binary_id
    field :reservations, {:array, ReservationEntity}, default: []
  end

  def apply(state, %PersonCreated{id: id}),
    do: put_id(state, id)

  def apply(%{reservations: reservations} = state, %ReservationAdded{reservation_id: id}) do
    reservation = ReservationEntity.new(id: id)
    put_reservations(state, [reservation | reservations])
  end
end
