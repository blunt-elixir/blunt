defmodule Cqrs.MessageTest do
  use ExUnit.Case, async: true
  alias Cqrs.MessageTest.Protocol

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

    test "has __message_type__ function" do
      assert :message == Simple.__message_type__()
    end
  end

  describe "field options" do
    alias Protocol.FieldOptions

    test "name is required" do
      assert {:error, %{name: ["can't be blank"]}} = FieldOptions.new(%{})
      assert {:ok, %FieldOptions{gender: nil, name: "chris"}} = FieldOptions.new(%{name: "chris"})
    end

    test "can accept values from different data structures" do
      assert {:ok, %FieldOptions{gender: nil, name: "chris"}} = FieldOptions.new(%{name: "chris"})
      assert {:ok, %FieldOptions{gender: nil, name: "chris"}} = FieldOptions.new(name: "chris")
    end

    test "dog defaults to the default option" do
      assert {:ok, %FieldOptions{gender: :m, name: "chris", dog: "maize"}} = FieldOptions.new(name: "chris", gender: :m)
    end
  end

  describe "message options" do
    alias Protocol.MessageOptions

    test "list options" do
      options = MessageOptions.__options__() |> Enum.into(%{})

      assert %{
               audit: [{:type, :boolean}, {:required, false}, {:default, true}],
               debug: [{:type, :boolean}, {:required, false}, {:default, false}]
             } == options
    end
  end
end
