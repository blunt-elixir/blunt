defmodule Cqrs.Message.Metadata do
  def record(name, value) do
    quote do
      @metadata {unquote(name), unquote(value)}
    end
  end

  def fetch!(module, key) do
    module
    |> get_all()
    |> Keyword.fetch!(key)
  end

  def get_all(module) do
    :attributes
    |> module.__info__()
    |> Keyword.get_values(:metadata)
    |> List.flatten()
  end

  def get(module, key, default \\ nil) do
    module
    |> get_all()
    |> Keyword.get(key, default)
  end

  def get_values(module, key) do
    module
    |> get_all()
    |> Keyword.get_values(key)
  end
end
