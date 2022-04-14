defmodule Blunt.Data.Factories.Values.RemoveProp do
  @moduledoc false
  defstruct [:field]

  alias Blunt.Data.Factories.Factory
  alias Blunt.Data.Factories.Values.RemoveProp

  defimpl Blunt.Data.Factories.Value do
    def evaluate(%RemoveProp{field: field}, acc, current_factory) do
      if Map.has_key?(acc, field) do
        {removed_value, acc} = Map.pop!(acc, field)
        Factory.log_value(current_factory, removed_value, field, false, "removed")
        acc
      else
        acc
      end
    end
  end
end
