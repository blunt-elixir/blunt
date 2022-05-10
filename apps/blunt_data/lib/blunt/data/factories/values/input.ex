defmodule Blunt.Data.Factories.Values.Input do
  @moduledoc false
  defstruct [:props]

  alias Blunt.Data.Factories.Factory
  alias Blunt.Data.Factories.Values.Input

  defimpl Blunt.Data.Factories.Value do
    def declared_props(%Input{}), do: []

    def evaluate(%Input{props: props}, acc, current_factory) do
      {kept, removed} = Map.split(acc, props)
      removed_keys = Map.keys(removed)

      Factory.log_value(current_factory, removed_keys, "input", false, "removed")
      Factory.log_value(current_factory, kept, "input", false, "kept")

      kept
    end
  end
end
