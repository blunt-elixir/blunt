defmodule Blunt.Data.Factories.Values.Defaults do
  @moduledoc false
  defstruct values: %{}

  alias Blunt.Data.Factories.Factory
  alias Blunt.Data.Factories.Values.Defaults

  defimpl Blunt.Data.Factories.Value do
    def declared_props(%Defaults{values: values}), do: Map.keys(values)

    def evaluate(%Defaults{values: values}, acc, current_factory) do
      Enum.reduce(values, acc, fn
        {key, _value}, acc when is_map_key(acc, key) ->
          acc

        {key, value}, acc ->
          value = Factory.log_value(current_factory, value, key, false, "default")
          Map.put(acc, key, value)
      end)
    end
  end
end
