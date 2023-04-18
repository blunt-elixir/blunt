defmodule Blunt.Data.Factories.Values.RemoveProp do
  @moduledoc false
  defstruct [:fields]

  alias Blunt.Data.Factories.{Factory, Value}
  alias Blunt.Data.Factories.Values.RemoveProp

  defimpl Blunt.Data.Factories.Value do
    def declared_props(%RemoveProp{}), do: []

    def error(_value, error, current_factory),
      do: raise(Blunt.Data.Factories.ValueError, factory: current_factory, error: error, prop: :remove_prop)

    def evaluate(%RemoveProp{fields: :undeclared}, acc, current_factory) do
      keys =
        current_factory.values
        |> Enum.flat_map(&Value.declared_props/1)
        |> Enum.uniq()

      {keep, drop} = Map.split(acc, keys)

      Factory.log_value(current_factory, Map.keys(drop), "props", false, "removed")
      Factory.log_value(current_factory, Map.keys(keep), "props", false, "kept")

      keep
    end

    def evaluate(%RemoveProp{fields: fields}, acc, current_factory) do
      Enum.reduce(fields, acc, fn field, acc ->
        if Map.has_key?(acc, field) do
          {_removed_value, acc} = Map.pop!(acc, field)
          Factory.log_value(current_factory, :removed, field, false, "removed")
          acc
        else
          acc
        end
      end)
    end
  end
end
