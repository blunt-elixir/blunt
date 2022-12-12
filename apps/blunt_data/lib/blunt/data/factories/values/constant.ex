defmodule Blunt.Data.Factories.Values.Constant do
  alias Blunt.Data.Factories.Factory
  alias Blunt.Data.Factories.Values.Constant

  @moduledoc false
  @derive Inspect
  defstruct [:field, :value]

  defimpl Blunt.Data.Factories.Value do
    def evaluate(%Constant{field: field, value: value}, acc, current_factory) do
      value = Factory.log_value(current_factory, value, field, false, "const")
      Map.put(acc, field, value)
    end

    def declared_props(%Constant{field: field}), do: [field]

    def error(%{field: field}, error, current_factory),
      do: raise(Blunt.Data.Factories.ValueError, factory: current_factory, error: error, prop: field)
  end
end
