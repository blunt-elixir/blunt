defmodule Blunt.ValueObject.Equality do
  require Logger

  defmacro __using__(_opts) do
    quote do
      def equals?(left, right),
        do: unquote(__MODULE__).equals?(__MODULE__, left, right)
    end
  end

  def equals?(_module, nil, _), do: false
  def equals?(_module, _, nil), do: false

  def equals?(module, %{__struct__: module} = left, %{__struct__: module} = right) do
    left = Map.delete(left, :__blunt_id)
    right = Map.delete(right, :__blunt_id)
    Map.equal?(left, right)
  end

  def equals?(module, _left, _right) do
    Logger.warn("#{inspect(module)}.equals? requires two #{inspect(module)} structs")
    false
  end
end
