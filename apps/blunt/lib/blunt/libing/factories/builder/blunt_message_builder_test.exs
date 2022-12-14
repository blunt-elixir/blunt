defmodule Blunt.Testing.Factories.Builder.BluntMessageBuilderTest do
  use ExUnit.Case
  alias Blunt.Testing.Factories.Builder.BluntMessageBuilder

  describe "internal fields with a type of map" do
    defmodule Testing do
      use Blunt.Command
      internal_field :data, :map
    end

    test "transform string key map into atom key map" do
      assert %{data: %{name: "stoobz"}} = BluntMessageBuilder.build(Testing, %{data: %{name: "stoobz"}})
      assert %{data: %{name: "stoobz"}} = BluntMessageBuilder.build(Testing, %{data: %{"name" => "stoobz"}})
    end
  end
end
