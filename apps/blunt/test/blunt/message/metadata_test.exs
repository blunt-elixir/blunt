defmodule Blunt.Message.MetadataTest do
  use ExUnit.Case
  alias Blunt.Message.Metadata

  defmodule MyMessage do
    use Blunt.Message, force_jason_encoder?: true

    field :name, :string
    field :dog, :enum, values: [:jake, :maize]
    internal_field :calculated, :string, virtual: true
  end

  describe "virutal fields" do
    test "field names" do
      assert [:__blunt_id, :calculated] == Metadata.field_names(MyMessage, :virtual)
    end

    test "are not json serialized" do
      {:ok, message} = MyMessage.new(name: "chris", dog: :maize, calculated: "thing")

      rehydrated_map =
        message
        |> Jason.encode!()
        |> Jason.decode!()

      refute Map.has_key?(rehydrated_map, "calculated")

      assert {:ok, %MyMessage{dog: :maize, name: "chris", calculated: nil}} = MyMessage.new(rehydrated_map)
    end
  end
end
