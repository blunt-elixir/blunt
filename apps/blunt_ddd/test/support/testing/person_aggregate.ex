defmodule Support.Testing.PersonAggregate do
  use Blunt.Ddd

  alias Support.Testing.{CreatePerson, PersonCreated}
  alias Support.Testing.{AddReservation, ReservationAdded, ReservationEntity}

  defstate do
    field :id, :binary_id
    field :reservations, {:array, ReservationEntity}, default: []
  end

  def execute(%{id: nil}, %CreatePerson{} = command),
    do: CreatePerson.person_created(command)

  def execute(_state, %CreatePerson{}),
    do: {:error, "person already created"}

  def execute(%{id: nil}, _command),
    do: {:error, "person not found"}

  def execute(%{id: person_id, reservations: reservations}, %AddReservation{id: reservation_id} = command) do
    reservation = ReservationEntity.new(id: reservation_id)

    if Enum.any?(reservations, &ReservationEntity.equals?(&1, reservation)),
      do: nil,
      else: ReservationAdded.new(command, person_id: person_id)
  end

  def apply(state, %PersonCreated{id: id}),
    do: put_id(state, id)

  def apply(%{reservations: reservations} = state, %ReservationAdded{id: id}) do
    reservation = ReservationEntity.new(id: id)
    put_reservations(state, [reservation | reservations])
  end
end
