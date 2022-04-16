defmodule Blunt.Data.Factories.Values.Mapper do
  @moduledoc false
  defstruct [:func]

  alias Blunt.Data.Factories.Values.Mapper
  alias Blunt.Data.Factories.{Factory, Value}

  defimpl Blunt.Data.Factories.Value do
    def declared_props(%Mapper{}), do: []

    def evaluate(%Mapper{func: :declared_only}, acc, current_factory) do
      keys =
        current_factory.values
        |> Enum.flat_map(&Value.declared_props/1)
        |> Enum.uniq()

      value = Map.take(acc, keys)
      Factory.log_value(current_factory, value, "factory data", false, "map")
    end

    def evaluate(%Mapper{func: func}, acc, current_factory) do
      value = func.(acc)
      Factory.log_value(current_factory, value, "factory data", false, "map")
    end
  end
end
