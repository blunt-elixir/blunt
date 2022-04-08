defmodule Blunt.Message.Schema.BuiltInValidationsTest do
  use ExUnit.Case, async: true

  defmodule MyQuery do
    use Blunt.Query

    field :code, :string
    field :id, :string

    require_at_least_one([:code, :id])
  end

  describe "require_at_least_one" do
    test "error" do
      assert {:error,
              %{
                fields: ["expected at least one of following fields to be supplied: [:code, :id]"]
              }} = MyQuery.new([])
    end

    test "ok" do
      assert {:ok, %{id: "123"}} = MyQuery.new(id: "123")
      assert {:ok, %{code: "123"}} = MyQuery.new(code: "123")
    end
  end

  describe "require_either" do
    defmodule RequireEitherQuery do
      use Blunt.Query

      field :id, :binary_id
      field :product_id, :binary_id
      field :label, :string

      require_either([:id, [:product_id, :label]])
    end

    test "error" do
      assert {:error, %{fields: ["expected either :id OR (:product_id AND :label) to be present"]}} =
               RequireEitherQuery.new([])
    end
  end
end
