defmodule Blunt.Absinthe.MutationTest do
  use ExUnit.Case
  alias Blunt.Absinthe.Test.Schema

  setup do
    %{
      query: """
      mutation create($name: String!, $gender: Gender!){
        createPerson(name: $name, gender: $gender){
          id
          name
          gender
        }
      }
      """
    }
  end

  test "field documentation is copied from Query" do
    assert %{description: "Creates's a person."} =
             Absinthe.Schema.lookup_type(Schema, "RootMutationType")
             |> Map.get(:fields)
             |> Map.get(:create_person)
  end

  test "internal field id is not an arg" do
    assert %{fields: %{create_person: %{args: args}}} = Absinthe.Schema.lookup_type(Schema, "RootMutationType")
    refute Enum.member?(Map.keys(args), :id)
  end

  test "can create a person", %{query: query} do
    assert {:ok, %{data: %{"createPerson" => person}}} =
             Absinthe.run(query, Schema, variables: %{"name" => "chris", "gender" => "MALE"})

    assert %{"id" => id, "name" => "chris", "gender" => "MALE"} = person
    assert {:ok, _} = UUID.info(id)
  end
end
