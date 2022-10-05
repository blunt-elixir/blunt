defmodule Blunt.Absinthe.MutationTest do
  use ExUnit.Case

  alias Absinthe.Type.{InputObject, Object}

  alias Blunt.DispatchContext
  alias Blunt.Absinthe.Test.Schema

  setup do
    %{
      query: """
      mutation create($name: String!, $gender: Gender!, $address: AddressInput){
        createPerson(name: $name, gender: $gender, address: $address){
          id
          name
          gender
          address {
            line1
            line2
          }
        }
      }
      """,
      update_query: """
      mutation update($input: UpdatePersonInput){
        updatePerson(input: $input){
          id
          name
          gender
          address {
            line1
            line2
          }
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
             Absinthe.run(query, Schema,
               variables: %{"name" => "chris", "gender" => "MALE", "address" => %{"line1" => "42 Infinity Ave"}}
             )

    assert %{"id" => id, "name" => "chris", "gender" => "MALE", "address" => %{"line1" => "42 Infinity Ave"}} = person
    assert {:ok, _} = UUID.info(id)
  end

  test "returns errors", %{query: query} do
    assert {:ok, %{errors: [%{message: message}]}} =
             Absinthe.run(query, Schema, variables: %{"name" => "chris", "gender" => ""})

    assert message =~ "gender"
  end

  test "returns errors for absinthe type mismatch", %{query: query} do
    assert {:ok, %{errors: [%{message: message}]}} =
             Absinthe.run(query, Schema,
               variables: %{
                 "name" => "chris",
                 "gender" => "MALE",
                 "address" => %{}
               }
             )

    assert message =~ ~r/address.*\n.*line1.*found null/
  end

  test "returns errors from nested changeset validations", %{query: query} do
    assert {:ok, %{errors: [%{message: message}]}} =
             Absinthe.run(query, Schema,
               variables: %{
                 "name" => "chris",
                 "gender" => "MALE",
                 "address" => %{"line1" => "--"}
               }
             )

    assert message =~ "address.line1 should be at least 3 character(s)"
  end

  test "user is put in the context from absinthe resolution context", %{query: query} do
    context = %{user: %{name: "chris"}, reply_to: self()}

    _ = Absinthe.run(query, Schema, context: context, variables: %{"name" => "chris", "gender" => "MALE"})

    assert_receive {:context, %DispatchContext{user: %{name: "chris"}}}
  end

  test "mutation input types" do
    assert %InputObject{fields: fields} = Absinthe.Schema.lookup_type(Schema, :update_person_input)

    assert %{
             id: %{
               type: %Absinthe.Type.NonNull{of_type: :id}
             },
             name: %{
               type: %Absinthe.Type.NonNull{of_type: :string}
             },
             gender: %{
               type: :gender
             },
             address: %{
               type: :address_input
             }
           } = fields
  end

  test "derive object" do
    assert %Object{fields: fields} = Absinthe.Schema.lookup_type(Schema, :dog)
    assert %{name: %{type: :string}} = fields
  end

  test "returns errors from deeper nested changeset validations", %{update_query: update_query} do
    assert {:ok, %{errors: [%{message: message}]}} =
             Absinthe.run(update_query, Schema,
               variables: %{
                 "input" => %{
                   "id" => UUID.uuid4(),
                   "name" => "chris",
                   "gender" => "MALE",
                   "address" => %{"line1" => "--"}
                 }
               }
             )

    assert message =~ "address.line1 should be at least 3 character(s)"
  end
end
