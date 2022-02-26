defmodule Blunt.EntityTest do
  use ExUnit.Case, async: true

  alias Blunt.Message.Metadata
  alias Blunt.EntityTestMessages.Protocol.{Entity1, Entity2}

  test "entity has id field by default" do
    fields = Entity1.__schema__(:fields)
    assert Enum.member?(fields, :id)
  end

  test "entities with no fields defined have new/1 and new/2 functions" do
    assert [1, 2] == Entity1.__info__(:functions) |> Keyword.get_values(:new)
  end

  test "entities can't be dispatched" do
    assert Entity1.__info__(:functions)[:dispatch] == nil
  end

  test "entities required their primary key to assigned" do
    assert {:error, %{id: ["can't be blank"]}} = Entity1.new(%{})
    assert {:error, %{id: ["is invalid"]}} = Entity1.new(%{id: "2342"})
    id = UUID.uuid4()
    assert %Entity1{id: ^id} = Entity1.new(id: id)
  end

  describe "equality" do
    test "entities have identity function" do
      assert [1] == Entity1.__info__(:functions) |> Keyword.get_values(:identity)
    end

    test "entities have equals? function" do
      assert [2] == Entity1.__info__(:functions) |> Keyword.get_values(:equals?)
    end

    test "entities can only check equality of same entity types" do
      one = Entity1.new(id: UUID.uuid4())
      two = Entity2.new(ident: UUID.uuid4())

      error =
        "Blunt.EntityTestMessages.Protocol.Entity1.equals? requires two Blunt.EntityTestMessages.Protocol.Entity1 structs"

      assert_raise Blunt.Entity.Error, error, fn ->
        Entity1.equals?(one, two)
      end
    end

    test "identity works" do
      id = UUID.uuid4()
      assert id == Entity1.new(id: id) |> Entity1.identity()
    end

    test "equality check works" do
      one = Entity1.new(id: UUID.uuid4())
      two = Entity1.new(id: UUID.uuid4())

      assert false == Entity1.equals?(one, two)

      id = UUID.uuid4()
      left = Entity1.new(id: id)
      right = Entity1.new(id: id)
      assert true == Entity1.equals?(left, right)
    end
  end

  describe "custom primary key" do
    test "unable to set to false" do
      code = """
      defmodule E do
        use Blunt.Entity, identity: false
      end
      """

      assert_raise Blunt.Entity.Error, "Entities require a primary key", fn ->
        Code.compile_string(code)
      end
    end

    test "unable to set to nil" do
      code = """
      defmodule E do
        use Blunt.Entity, identity: nil
      end
      """

      assert_raise Blunt.Entity.Error, "Entities require a primary key", fn ->
        Code.compile_string(code)
      end
    end

    test "must be tuple" do
      code = """
      defmodule E do
        use Blunt.Entity, identity: :abc
      end
      """

      assert_raise Blunt.Entity.Error,
                   "identity must be either {name, type} or {name, type, options}",
                   fn ->
                     Code.compile_string(code)
                   end
    end

    test "can customize identity field" do
      refute Metadata.has_field?(Entity2, :id)
      assert Metadata.has_field?(Entity2, :ident)
      assert Ecto.UUID = Entity2.__schema__(:type, :ident)
    end
  end
end
