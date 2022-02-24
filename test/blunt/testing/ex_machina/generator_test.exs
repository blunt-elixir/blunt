defmodule Blunt.Testing.ExMachina.GeneratorTest do
  use ExUnit.Case, async: true
  alias Blunt.Testing.ExMachina.Generator

  describe "populate_data_from_opts" do
    test "path based population" do
      id = UUID.uuid4()

      attrs = %{person: %{id: id}}
      opts = [values: [id: [:person, :id]]]

      assert %{id: ^id} = Generator.populate_data_from_opts(attrs, opts)
    end

    test "func/0 based population" do
      id = UUID.uuid4()

      attrs = %{}
      opts = [values: [id: fn -> id end]]

      assert %{id: ^id} = Generator.populate_data_from_opts(attrs, opts)
    end

    test "func/1 based population" do
      id = UUID.uuid4()

      attrs = %{other_id: id}
      opts = [values: [id: fn %{other_id: id} -> id end]]

      assert %{id: ^id} = Generator.populate_data_from_opts(attrs, opts)
    end
  end
end
