defmodule Blunt.Absinthe.QueryTest do
  use ExUnit.Case

  alias Blunt.Repo
  alias Blunt.Absinthe.Test.Schema
  alias Blunt.Absinthe.Test.ReadModel.Person

  defp create_person(name) do
    %{id: UUID.uuid4(), name: name}
    |> Person.changeset()
    |> Repo.insert()
  end

  setup do
    assert {:ok, %{id: person_id}} = create_person("chris")

    %{
      person_id: person_id,
      query: """
      query person($id: ID!, $error_out: Boolean){
        getPerson(id: $id, errorOut: $error_out){
          id
          name
          }
        }
      """
    }
  end

  test "field documentation is copied from Query" do
    assert %{description: "Get's a person."} =
             Absinthe.Schema.lookup_type(Schema, "RootQueryType")
             |> Map.get(:fields)
             |> Map.get(:get_person)
  end

  test "get_user is a valid query", %{person_id: person_id, query: query} do
    assert {:ok, %{data: %{"getPerson" => %{"id" => ^person_id}}}} =
             Absinthe.run(query, Schema, variables: %{"id" => person_id})
  end

  test "errors are returned", %{person_id: person_id, query: query} do
    variables = %{"id" => person_id, "error_out" => true}

    assert {:ok, %{errors: [%{message: "sumting wong"}]}} = Absinthe.run(query, Schema, variables: variables)
  end
end
