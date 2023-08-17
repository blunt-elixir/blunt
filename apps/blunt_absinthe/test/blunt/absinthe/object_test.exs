defmodule Blunt.Absinthe.ObjectTest do
  use ExUnit.Case

  defmodule MyObject do
    use Blunt.ValueObject
    field :test, :map, default: %{}
  end

  defmodule Schema do
    use Absinthe.Schema
    use Blunt.Absinthe

    import_types(Types.Json)

    derive_object :my_object, MyObject, arg_types: [test: :json]

    input_object :my_input do
      import_fields(:my_object)
    end

    query do
      field :hello, :string, resolve: fn _, _ -> {:ok, "world"} end
    end
  end

  test "default value is encoded correctly" do
    {:ok, res} =
      """
      query IntrospectionQuery {
        __type(name: "MyInput"){
          inputFields{
            defaultValue
            name
          }
        }
      }
      """
      |> Absinthe.run(Schema)

    assert %{"defaultValue" => "{}", "name" => "test"} = get_in(res, [:data, "__type", "inputFields", Access.at(0)])
  end
end
