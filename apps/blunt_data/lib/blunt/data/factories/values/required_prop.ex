defmodule Blunt.Data.Factories.Values.RequiredProp do
  alias Blunt.Data.FactoryError
  alias Blunt.Data.Factories.Values.RequiredProp

  @moduledoc false
  @derive Inspect
  defstruct [:field]

  defimpl Blunt.Data.Factories.Value do
    def declared_props(%RequiredProp{field: field}), do: [field]

    def evaluate(%RequiredProp{field: field}, acc, current_factory) do
      case Map.get(acc, field) do
        nil -> raise FactoryError.required_field(current_factory, field)
        _present -> acc
      end
    end
  end
end
