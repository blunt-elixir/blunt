defmodule Cqrs.ExMachinaTest do
  use ExUnit.Case, async: true

  use Cqrs.Testing.ExMachina

  alias Support.Testing.{CreatePerson, GetPerson, PlainMessage, PlainMessage}

  factory GetPerson
  factory CreatePerson
  factory PlainMessage

  test "functions" do
    funcs = __MODULE__.__info__(:functions)

    assert [1] = Keyword.get_values(funcs, :get_person_factory)
    assert [1] = Keyword.get_values(funcs, :create_person_factory)

    assert [1, 2, 3] = Keyword.get_values(funcs, :dispatch)
    assert [2, 3, 4] = Keyword.get_values(funcs, :dispatch_list)
    assert [1, 2, 3] = Keyword.get_values(funcs, :dispatch_pair)
  end

  describe "queries" do
    test "build with data" do
      id = UUID.uuid4()
      assert %GetPerson{id: ^id} = build(:get_person, id: id)
    end

    test "build without data will generate fake data" do
      assert %GetPerson{id: id} = build(:get_person)
      assert {:ok, _} = UUID.info(id)
    end

    test "dispatch" do
      assert {:ok, %{id: id, name: "chris"}} = dispatch(:get_person)
      assert {:ok, _} = UUID.info(id)
    end
  end

  describe "commands" do
    test "build with data" do
      assert %CreatePerson{name: "chris"} = build(:create_person, id: UUID.uuid4(), name: "chris")
    end

    test "build without data will generate fake data" do
      assert %CreatePerson{id: id, name: name} = build(:create_person)
      assert {:ok, _} = UUID.info(id)
      refute name == nil
    end

    test "dispatch" do
      assert {:ok, {:dispatched, command}} = dispatch(:create_person)
      assert %CreatePerson{id: id, name: name} = command
      assert {:ok, _} = UUID.info(id)
      refute name == nil
    end
  end

  describe "plain messages" do
    test "build with data" do
      id = UUID.uuid4()
      assert %PlainMessage{name: "chris", id: id} = build(:plain_message, id: id, name: "chris")
      assert {:ok, _} = UUID.info(id)
    end

    test "build without data will generate fake data" do
      assert %PlainMessage{id: id, name: name} = build(:plain_message)
      assert {:ok, _} = UUID.info(id)
      refute name == nil
    end

    test "dispatch" do
      alias Cqrs.Testing.ExMachina.DispatchStrategy.Error

      assert_raise Error, "Support.Testing.PlainMessage is not a dispatchable message", fn ->
        dispatch(:plain_message)
      end
    end
  end

  defmodule FactoryOptionsMessage do
    use Cqrs.Message

    field :id, :binary_id
  end

  factory FactoryOptionsMessage,
    as: :my_message,
    values: [
      id: [:person, :id]
    ]

  test "can set factory values from values option" do
    id = UUID.uuid4()

    assert %FactoryOptionsMessage{id: ^id} = build(:my_message, person: %{id: id})
  end

  defmodule PlainStruct do
    defstruct [:id, :name]
  end

  factory PlainStruct

  test "can use plain structs" do
    assert %PlainStruct{name: "chris"} = build(:plain_struct, name: "chris")
  end
end
