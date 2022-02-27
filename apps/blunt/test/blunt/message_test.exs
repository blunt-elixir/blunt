defmodule Blunt.MessageTest do
  use ExUnit.Case, async: true
  alias Blunt.Message.Metadata
  alias Blunt.MessageTest.Protocol

  describe "simple message" do
    alias Protocol.Simple

    test "is struct" do
      %Simple{name: nil} = struct!(Simple)
    end

    test "is ecto schema" do
      assert [:name] == Simple.__schema__(:fields)
    end

    test "has changeset function" do
      assert [1, 2] == Simple.__info__(:functions) |> Keyword.get_values(:changeset)
    end

    test "has constructor function" do
      assert [0, 1, 2] == Simple.__info__(:functions) |> Keyword.get_values(:new)
    end

    test "has message_type" do
      assert :message == Metadata.message_type(Simple)
    end
  end

  test "internal fields are never required" do
    alias Protocol.MessageWithInternalField, as: Msg

    assert [:id] == Metadata.field_names(Msg)

    required_fields = Metadata.required_field_names(Msg)
    refute Enum.member?(required_fields, :id)
  end

  describe "field options" do
    alias Protocol.FieldOptions

    test "discarded data is returned" do
      assert {:ok, _, %{"weed" => :yes}} = FieldOptions.new(name: "chris", weed: :yes)
    end

    test "autogenerate field" do
      today = Date.utc_today()
      assert {:ok, %FieldOptions{today: ^today}, _} = FieldOptions.new(name: "chris", weed: :yes)
    end

    test "name is required" do
      assert {:error, %{name: ["can't be blank"]}} = FieldOptions.new(%{})
      assert {:ok, %FieldOptions{gender: nil, name: "chris"}, _discarded_data} = FieldOptions.new(%{name: "chris"})
    end

    test "can accept values from different data structures" do
      assert {:ok, %FieldOptions{gender: nil, name: "chris"}, _discarded_data} = FieldOptions.new(%{name: "chris"})
      assert {:ok, %FieldOptions{gender: nil, name: "chris"}, _discarded_data} = FieldOptions.new(name: "chris")
    end

    test "dog defaults to the default option" do
      assert {:ok, %FieldOptions{gender: :m, name: "chris", dog: "maize"}, _discarded_data} =
               FieldOptions.new(name: "chris", gender: :m)
    end
  end
end
