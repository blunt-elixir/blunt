defmodule Blunt.Data.Factories.Values.Build do
  @moduledoc false

  defstruct [:field, :factory_name]

  alias Blunt.Data.Factories.Factory
  alias Blunt.Data.Factories.Values.Build

  defimpl Blunt.Data.Factories.Value do
    def evaluate(%Build{field: field, factory_name: factory_name}, acc, current_factory) do
      factory_name = String.to_existing_atom("#{factory_name}_factory")
      value = apply(current_factory.factory_module, factory_name, [acc])
      value = Factory.log_value(current_factory, value, field, false, "child")
      Map.put(acc, field, value)
    end

    def declared_props(%Build{field: field}), do: [field]
  end
end
