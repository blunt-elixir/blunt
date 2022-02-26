defmodule Blunt.StateTest do
  use ExUnit.Case, async: true

  alias Support.StateTest.{PersonAggregateRoot, ReservationEntity}
  alias Support.StateTest.Protocol.{PersonCreated, ReservationAdded}

  test "initial aggregate state" do
    assert %{id: nil} = %PersonAggregateRoot{}
  end

  test "create person" do
    id = UUID.uuid4()

    event = PersonCreated.new(id: id, name: "chris")

    assert %{id: ^id, reservations: []} =
             %PersonAggregateRoot{}
             |> PersonAggregateRoot.apply(event)
  end

  test "add reservation" do
    person_id = UUID.uuid4()
    reservation_id = UUID.uuid4()

    events = [
      PersonCreated.new(id: person_id, name: "chris"),
      ReservationAdded.new(person_id: person_id, reservation_id: reservation_id)
    ]

    state = %PersonAggregateRoot{}

    assert %{id: ^person_id, reservations: [%{id: ^reservation_id}]} =
             Enum.reduce(events, state, &PersonAggregateRoot.apply(&2, &1))
  end

  describe "state functions" do
    test "put function" do
      state = %PersonAggregateRoot{}
      id = UUID.uuid4()
      assert %{id: ^id} = PersonAggregateRoot.put_id(state, id)
    end

    test "get function" do
      id = UUID.uuid4()
      state = %PersonAggregateRoot{id: id}
      assert id == PersonAggregateRoot.get_id(state)
    end

    test "update function" do
      state = %PersonAggregateRoot{id: "e8caa2e5-19fe-4da2-99e6-45b5f3429b5d"}

      id = UUID.uuid4()
      reservation_id = UUID.uuid4()
      entity = ReservationEntity.new(id: reservation_id)

      values = %{id: id, reservations: [entity]}

      assert %{id: ^id, reservations: [%{id: ^reservation_id}]} = PersonAggregateRoot.update(state, values)
    end
  end
end
