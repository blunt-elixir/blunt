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
      assert {:ok, %{id: "123"}, _} = MyQuery.new(id: "123")
      assert {:ok, %{code: "123"}, _} = MyQuery.new(code: "123")
    end
  end
end
