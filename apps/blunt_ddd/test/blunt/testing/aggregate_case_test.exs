if Code.ensure_loaded?(ExMachina) and Code.ensure_loaded?(Faker) do
  defmodule Blunt.Testing.AggregateCaseTest do
    use ExUnit.Case
    use Blunt.Testing.ExMachina

    alias Support.Testing.{CreatePerson, PersonAggregate, PersonCreated}

    use Blunt.Testing.AggregateCase, aggregate: PersonAggregate

    factory CreatePerson
    factory PersonCreated

    test "execute_command" do
      %{id: id} = create_person = build(:create_person)

      %{events: [event], state: state} = execute_command(create_person)

      assert %PersonCreated{id: ^id} = event
      assert %PersonAggregate{id: ^id, reservations: []} = state
    end

    test "execute_command with initial events" do
      id = UUID.uuid4()

      person_created = build(:person_created, id: id)
      create_person = build(:create_person, id: id)

      %{error: error, events: [], state: state} = execute_command([person_created], create_person)

      assert {:error, "person already created"} = error
      assert %PersonAggregate{id: ^id, reservations: []} = state
    end
  end
end
