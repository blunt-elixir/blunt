defprotocol Blunt.Data.Factories.Value do
  @fallback_to_any true
  def evaluate(value, acc, current_factory)
  def declared_props(value)
  def error(value, error, current_factory)
end

defmodule Blunt.Data.Factories.ValueError do
  defexception [:factory, :prop, :error]

  def message(%{factory: %{name: factory_name}, prop: prop, error: error}) do
    """
    factory: #{factory_name}
    prop: #{inspect(prop)}

    #{inspect(error)}
    """
  end
end

defimpl Blunt.Data.Factories.Value, for: Any do
  def declared_props(_value), do: []
  def evaluate(_value, acc, _current_factory), do: acc
  def error(value, error), do: error
end
