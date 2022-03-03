defmodule Blunt.Data.FactoriesTest do
  use ExUnit.Case, async: true
  use Blunt.Data.Factories

  defmodule CreatePerson do
    defstruct [:id, :name]
  end

  defmodule PlainMessage do
    defstruct [:id, :name]
  end

  factory CreatePerson

  factory PlainMessage do
    prop :id, &UUID.uuid4/0
  end

  test "the macro generated factory functions" do
    funcs = __MODULE__.__info__(:functions)

    assert [1] = Keyword.get_values(funcs, :plain_message_factory)

    assert [1, 2] = Keyword.get_values(funcs, :build)
    assert [2, 3] = Keyword.get_values(funcs, :build_list)
    assert [1, 2] = Keyword.get_values(funcs, :build_pair)
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
  end

  describe "value declarations" do
    defmodule FactoryWithValuesMessage do
      defstruct [:id, :name, :dog]
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

  describe "complex factories " do
    defmodule CreateProduct do
      defstruct [:id]
    end

    defmodule CreatePolicy do
      defstruct [:product_id, :id]
    end

    defmodule CreatePolicyFee do
      defstruct [:policy_id, :id]
    end

    factory :my_complex_setup, debug: false do
      const :test_name, :plain_map_factory
      const :request_id, "5d724533-6d4f-49d7-bb30-e34e5b8c79b1"
      lazy_data :product, CreateProduct

      lazy_data :policy, CreatePolicy do
        prop(:product_id, [:product, :id])
      end

      prop :product_id, [:product, :id]
      prop :policy_id, [:policy, :id]
    end

    test "plain maps are built using just value declarations" do
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
