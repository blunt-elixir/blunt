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
      assert [0, 1, 2, 3] == Simple.__info__(:functions) |> Keyword.get_values(:new)
    end

    test "has message_type" do
      assert :message == Metadata.message_type(Simple)
    end
  end

  test "internal fields are never required" do
    alias Protocol.MessageWithInternalField, as: Msg

    assert [:id] == Metadata.field_names(Msg)

    required_fields = Metadata.field_names(Msg, :required)
    refute Enum.member?(required_fields, :id)
  end

  describe "field options" do
    alias Protocol.FieldOptions

    test "autogenerate field" do
      today = Date.utc_today()
      assert {:ok, %FieldOptions{today: ^today}} = FieldOptions.new(name: "chris", weed: :yes)
    end

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

  describe "required fields with defaults" do
    defmodule ReqFieldWithDefaultMessage do
      use Blunt.Message

      field :validate, :boolean, default: false, required: true
    end

    test "will be set to default value if value passed is nil" do
      assert {:ok, %{validate: false}} = ReqFieldWithDefaultMessage.new(validate: nil)
    end
  end

  describe "static fields" do
    defmodule MessageWithStaticField do
      use Blunt.Message

      static_field(:name, :string, default: "chris")
    end

    test "are unsettable" do
      assert {:ok, %{name: "chris"}} = MessageWithStaticField.new(name: "flkajds")
      assert {:ok, %{name: "chris"}} = MessageWithStaticField.new()
    end
  end
end
