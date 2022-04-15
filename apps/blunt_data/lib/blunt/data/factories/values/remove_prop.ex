defmodule Blunt.Data.Factories.Values.RemoveProp do
  @moduledoc false
  defstruct [:fields]

  alias Blunt.Data.Factories.Factory
  alias Blunt.Data.Factories.Values.RemoveProp

  defimpl Blunt.Data.Factories.Value do
    def evaluate(%RemoveProp{fields: fields}, acc, current_factory) do
      Enum.reduce(fields, acc, fn field, acc ->
        if Map.has_key?(acc, field) do
          {removed_value, acc} = Map.pop!(acc, field)
          Factory.log_value(current_factory, removed_value, field, false, "removed")
          acc
        else
          acc
        end
      end)
    end
  end
end
