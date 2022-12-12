defmodule Blunt.Data.Factories.Values.RequiredProp do
  alias Blunt.Data.FactoryError
  alias Blunt.Data.Factories.Values.RequiredProp

  @moduledoc false
  @derive Inspect
  defstruct [:fields]

  defimpl Blunt.Data.Factories.Value do
    def declared_props(%RequiredProp{fields: fields}), do: fields

    def error(%{fields: fields}, error, current_factory),
      do: raise(Blunt.Data.Factories.ValueError, factory: current_factory, error: error, prop: inspect(fields))

    def evaluate(%RequiredProp{fields: fields}, acc, current_factory) do
      results =
        Enum.reduce(fields, [], fn field, results ->
          case Map.get(acc, field) do
            nil -> [{:error, field} | results]
            _present -> [{:ok, acc} | results]
          end
        end)

      {_, errors} = Enum.split_with(results, &(elem(&1, 0) == :ok))

      with [_ | _] <- errors do
        fields = Enum.map(errors, &elem(&1, 1))
        raise FactoryError.required_field(current_factory, fields)
      end

      acc
    end
  end
end
