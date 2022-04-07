defmodule Blunt.Data.FactoryError do
  defexception [:reason, :factory]

  def message(%{reason: :unauthorized, factory: %{name: name, message: message}}) do
    "#{name} factory was unauthorized while building #{inspect(message)}"
  end

  def message(%{reason: reason, factory: %{name: name, message: message}}) do
    "#{name} factory failed while building #{inspect(message)}. #{reason}"
  end
end
