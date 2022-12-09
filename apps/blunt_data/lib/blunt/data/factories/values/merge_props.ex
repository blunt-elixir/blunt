defmodule Blunt.Data.Factories.Values.MergeProps do
  defstruct [:prop]

  alias Blunt.Data.Factories.Factory
  alias Blunt.Data.Factories.Values.MergeProps

  defimpl Blunt.Data.Factories.Value do
    def declared_props(%MergeProps{}), do: []

    def evaluate(%MergeProps{prop: prop}, factory_data, current_factory) do
      case Map.pop(factory_data, prop) do
        {%{} = map, factory_data} ->
          Factory.log_value(current_factory, map, prop, false, "merge props")
          Map.merge(factory_data, map)

        {_, factory_data} ->
          factory_data
      end
    end
  end
end
