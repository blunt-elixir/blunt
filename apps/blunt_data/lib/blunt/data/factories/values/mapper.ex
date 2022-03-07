defmodule Blunt.Data.Factories.Values.Mapper do
  @moduledoc false
  defstruct [:func]

  alias Blunt.Data.Factories.Factory
  alias Blunt.Data.Factories.Values.Mapper

  defimpl Blunt.Data.Factories.Value do
    def evaluate(%Mapper{func: func}, acc, current_factory) do
      value = func.(acc)
      Factory.log_value(current_factory, value, "data", false, "map")
    end
  end
end
