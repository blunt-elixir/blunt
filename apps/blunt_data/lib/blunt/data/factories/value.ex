defprotocol Blunt.Data.Factories.Value do
  def evaluate(value, acc, current_factory)
  def declared_props(value)
end
