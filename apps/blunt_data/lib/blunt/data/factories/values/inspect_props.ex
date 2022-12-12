defmodule Blunt.Data.Factories.Values.InspectProps do
  @moduledoc false
  defstruct [:props]

  alias Blunt.Data.Factories.{Factory, Value}
  alias Blunt.Data.Factories.Values.InspectProps

  defimpl Blunt.Data.Factories.Value do
    def declared_props(%InspectProps{}), do: []

    def error(_value, error, current_factory),
      do: raise(Blunt.Data.Factories.ValueError, factory: current_factory, error: error, prop: :inspect_props)

    def evaluate(%InspectProps{props: :declared}, acc, current_factory) do
      keys =
        current_factory.values
        |> Enum.flat_map(&Value.declared_props/1)
        |> Enum.uniq()

      value = Map.take(acc, keys)

      current_factory
      |> Factory.enable_debug()
      |> Factory.log_value(value, "declared props", false, "inspect")

      acc
    end

    def evaluate(%InspectProps{props: :all}, acc, current_factory) do
      current_factory
      |> Factory.enable_debug()
      |> Factory.log_value(acc, "all props", false, "inspect")
    end

    def evaluate(%InspectProps{props: :__keys}, acc, current_factory) do
      keys = acc |> Map.keys() |> Enum.sort()

      current_factory
      |> Factory.enable_debug()
      |> Factory.log_value(keys, "all props keys", false, "inspect")

      acc
    end

    def evaluate(%InspectProps{props: props}, acc, current_factory) do
      value = Map.take(acc, props)

      current_factory
      |> Factory.enable_debug()
      |> Factory.log_value(value, "props", false, "inspect")

      acc
    end
  end
end
