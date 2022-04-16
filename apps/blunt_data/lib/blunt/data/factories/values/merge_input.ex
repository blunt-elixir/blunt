defmodule Blunt.Data.Factories.Values.MergeInput do
  @moduledoc false
  defstruct [:key, :opts]

  alias Blunt.Data.Factories.Factory
  alias Blunt.Data.Factories.Values.MergeInput

  defimpl Blunt.Data.Factories.Value do
    def declared_props(%MergeInput{}), do: []

    def evaluate(%MergeInput{key: key, opts: opts}, acc, current_factory) do
      case Map.pop(acc, key, %{}) do
        {input, acc} when is_map(input) ->
          only = Keyword.get(opts, :only, [])
          except = Keyword.get(opts, :except, [])

          input =
            case {only, except} do
              {[], []} -> input
              {[], except} -> Map.drop(input, except)
              {only, []} -> Map.take(input, only)
              _ -> raise "#{current_factory.name} you may only specify only or except"
            end

          input = Factory.log_value(current_factory, input, "data", false, "merge")
          Map.merge(input, acc)

        {input, acc} ->
          Map.put(acc, key, input)
      end
    end
  end
end
