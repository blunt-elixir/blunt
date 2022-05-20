defprotocol Blunt.Data.Factories.Value do
  @fallback_to_any true
  def evaluate(value, acc, current_factory)
  def declared_props(value)
end

defimpl Blunt.Data.Factories.Value, for: Any do
  def declared_props(_value), do: []
  def evaluate(_value, acc, _current_factory), do: acc
end
