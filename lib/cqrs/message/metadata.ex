defmodule Cqrs.Message.Metadata do
  def record(name, value) do
    quote do
      @metadata {unquote(name), unquote(value)}
    end
  end
end
