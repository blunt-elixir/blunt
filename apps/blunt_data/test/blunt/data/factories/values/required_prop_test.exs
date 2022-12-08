defmodule Blunt.Data.Factories.Values.RequiredPropTest do
  use ExUnit.Case
  alias Blunt.Data.FactoryError
  alias Blunt.Data.Factories.Value
  alias Blunt.Data.Factories.Values.RequiredProp

  test "evaluation" do
    alias Blunt.Data.FactoryError

    %FactoryError{data: [:dog, :name]} =
      assert_raise(FactoryError, fn ->
        Value.evaluate(%RequiredProp{fields: [:name, :dog]}, %{}, %{name: :test, message: %{}})
      end)

    %FactoryError{data: [:name]} =
      assert_raise(FactoryError, fn ->
        Value.evaluate(%RequiredProp{fields: [:name, :dog]}, %{dog: :maize}, %{name: :test, message: %{}})
      end)
  end
end
