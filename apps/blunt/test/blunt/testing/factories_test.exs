defmodule Blunt.Testing.FactoriesTest do
  use ExUnit.Case, async: true
  @moduletag :skip

  use Blunt.Testing.Factories

  alias Support.Testing.{CreatePerson, GetPerson, PlainMessage, PlainMessage}
  alias Support.Testing.LayzFactoryValueMessages.{CreatePolicyFee, CreatePolicy, CreateProduct}

  factory GetPerson
  factory CreatePerson
  factory PlainMessage

  test "the macro generated factory functions" do
    funcs = __MODULE__.__info__(:functions)

    assert [1] = Keyword.get_values(funcs, :get_person_factory)
    assert [1] = Keyword.get_values(funcs, :create_person_factory)

    assert [1, 2, 3] = Keyword.get_values(funcs, :bispatch)
    assert [2, 3, 4] = Keyword.get_values(funcs, :bispatch_list)
    assert [1, 2, 3] = Keyword.get_values(funcs, :bispatch_pair)
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

    test "bispatch" do
      assert {:ok, %{id: id, name: "chris"}} = bispatch(:get_person)
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

    test "bispatch" do
      assert {:ok, {:dispatched, command}} = bispatch(:create_person)
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

    test "bispatch" do
      alias Blunt.Testing.Factories.DispatchStrategy.Error

      assert_raise Error, "Support.Testing.PlainMessage is not a dispatchable message", fn ->
        bispatch(:plain_message)
      end
    end
  end

  describe "value declarations" do
    defmodule FactoryWithValuesMessage do
      use Blunt.Message

      field :id, :binary_id
      field :name, :string
      field :dog, :string
    end

    factory FactoryWithValuesMessage, as: :my_message do
      const :dog, "maize"
      prop :id, [:person, :id]
      prop :name, [:person, :name]
    end

    test "factory values" do
      id = UUID.uuid4()

      person = %{id: id, name: "chris", dog: "maize"}

      assert %FactoryWithValuesMessage{id: ^id, name: "chris", dog: "maize"} = build(:my_message, person: person)
    end
  end

  describe "prop func values" do
    defmodule MessageWithPropFuncValues do
      defstruct [:name, :id, :name_id]
    end

    factory MessageWithPropFuncValues do
      prop :name, fn ->
        send(self(), :name_generated)
        Faker.Person.name()
      end

      prop :name_id, fn %{name: name} ->
        send(self(), :name_id_generated)
        UUID.uuid5(:oid, name)
      end

      const :id, 123
    end

    test "are populated" do
      assert %MessageWithPropFuncValues{id: 123, name: name, name_id: name_id} = build(:message_with_prop_func_values)

      assert_received :name_generated
      assert_received :name_id_generated

      assert {:ok, _} = UUID.info(name_id)

      refute name == nil
    end
  end

  describe "plain structs" do
    defmodule PlainStruct do
      defstruct [:id, :name]
    end

    factory PlainStruct do
      const :id, 138
    end

    test "can be built" do
      assert %PlainStruct{id: 138, name: "chris"} = build(:plain_struct, name: "chris")
    end
  end

  describe "plain modules" do
    alias Blunt.Data.Factories.Builder.NoBuilderError

    defmodule NonStruct do
    end

    factory CreatePolicyFee, as: :create_policy_fee2, debug: false do
      lazy_data :policy, NonStruct do
        prop(:product_id, [:product, :id])
      end

      prop :policy_id, [:policy, :id]
    end

    test "can not be used as a lazy factory" do
      assert_raise NoBuilderError, fn ->
        bispatch(:create_policy_fee2)
      end
    end
  end

  describe "fake enum values" do
    defmodule MessageWithEnum do
      use Blunt.Message
      field :pet, :enum, values: [:cat, :dog]
    end

    factory MessageWithEnum

    test "pet is populated correctly" do
      assert %MessageWithEnum{pet: pet} = build(:message_with_enum)
      assert Enum.member?([:cat, :dog], pet)
    end
  end

  describe "plain maps" do
    factory CreatePolicyFee, debug: false do
      lazy_data :product, CreateProduct

      lazy_data :policy, CreatePolicy do
        prop :product_id, [:product, :id]
      end

      prop :policy_id, [:policy, :id]
    end

    factory :my_complex_setup, debug: false do
      const :test_name, :plain_map_factory
      const :request_id, "5d724533-6d4f-49d7-bb30-e34e5b8c79b1"
      lazy_data :product, CreateProduct

      lazy_data :policy, CreatePolicy do
        prop :product_id, [:product, :id]
      end

      prop :product_id, [:product, :id]
      prop :policy_id, [:policy, :id]
    end

    test "can be built using just value declarations" do
      assert %{
               product: %{id: product_id},
               policy: %{id: policy_id},
               policy_id: policy_id,
               product_id: product_id,
               request_id: "5d724533-6d4f-49d7-bb30-e34e5b8c79b1",
               test_name: :plain_map_factory
             } = build(:my_complex_setup)
    end
  end
end
