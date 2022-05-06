defmodule Blunt.ValueObjectTest do
  use ExUnit.Case
  import ExUnit.CaptureLog

  defmodule SomeObject do
    use Blunt.ValueObject

    field :one, :integer
    field :two, :string
  end

  describe "equality" do
    test "same objects are equal" do
      obj = SomeObject.new(one: 1, two: "2")
      assert SomeObject.equals?(obj, obj)
    end

    test "two objects with same values are equal" do
      left = SomeObject.new(one: 1, two: "2")
      right = SomeObject.new(one: 1, two: "2")
      assert SomeObject.equals?(left, right)
    end

    test "two objects with differnt values are not equal" do
      left = SomeObject.new(one: 1, two: "2")
      right = SomeObject.new(one: 1, two: "two")
      refute SomeObject.equals?(left, right)
    end

    test "two different objects with differnt values are not equal" do
      left = SomeObject.new(one: 1, two: "2")
      right = %{one: 1, two: "two"}

      error = "Blunt.ValueObjectTest.SomeObject.equals? requires two Blunt.ValueObjectTest.SomeObject structs"

      capture_log(fn -> refute SomeObject.equals?(left, right) end) =~ error
    end

    test "two maps with same values are not equal" do
      left = %{one: 1, two: "2"}
      right = %{one: 1, two: "two"}
      error = "Blunt.ValueObjectTest.SomeObject.equals? requires two Blunt.ValueObjectTest.SomeObject structs"

      capture_log(fn -> refute SomeObject.equals?(left, right) end) =~ error
    end
  end
end
