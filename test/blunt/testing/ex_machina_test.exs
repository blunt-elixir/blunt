defmodule Blunt.ExMachinaTest do
  use ExUnit.Case, async: true

  use Blunt.Testing.ExMachina

  alias Support.Testing.{CreatePerson, GetPerson, PlainMessage, PlainMessage}

  factory GetPerson
  factory CreatePerson
  factory PlainMessage

  test "generated functions" do
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
      alias Blunt.Testing.ExMachina.DispatchStrategy.Error

      assert_raise Error, "Support.Testing.PlainMessage is not a dispatchable message", fn ->
        dispatch(:plain_message)
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
    defmodule MessageWithFakes do
      defstruct [:name, :id, :name_id]
    end

    factory MessageWithFakes do
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
      assert %MessageWithFakes{id: 123, name: name, name_id: name_id} = build(:message_with_fakes)

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

  describe "lazy values" do
    alias Support.Testing.LayzFactoryValueMessages.{CreatePolicyFee, CreatePolicy, CreateProduct}

    factory CreatePolicyFee, debug: false do
      lazy :product, CreateProduct
      lazy :policy, CreatePolicy, [prop(:product_id, [:product, :id])]
      prop :policy_id, [:policy, :id]
    end

    test "are evaluated in order of declaration" do
      fee_id = UUID.uuid4()

      assert {:ok, %{id: ^fee_id, policy_id: policy_id}} = dispatch(:create_policy_fee, id: fee_id)

      assert {:ok, _} = UUID.info(policy_id)
    end

    test "lazy values will not overwrite existing values" do
      fee_id = UUID.uuid4()
      policy_id = UUID.uuid4()
      policy = %{id: policy_id}

      assert {:ok, %{id: ^fee_id, policy_id: ^policy_id}} = dispatch(:create_policy_fee, id: fee_id, policy: policy)
    end
  end

  describe "plain modules" do
    defmodule NonStruct do
    end

    factory CreatePolicyFee, as: :create_policy_fee2 do
      lazy :policy, NonStruct, [prop(:product_id, [:product, :id])]
      prop :policy_id, [:policy, :id]
    end

    test "can not be used as a lazy factory" do
      fee_id = UUID.uuid4()

      assert_raise Blunt.Testing.ExMachina.Factory.Error, fn -> dispatch(:create_policy_fee2, id: fee_id) end
    end
  end
end
