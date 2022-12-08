defmodule Blunt.Data.FactoryError do
  defexception [:reason, :factory, :data]

  def required_field(factory, fields), do: %__MODULE__{reason: :required_field, data: fields, factory: factory}

  def message(%{reason: :unauthorized, factory: %{name: name, message: message}}) do
    "#{name} factory was unauthorized while building #{inspect(message)}"
  end

  def message(%{reason: :required_field, data: [field], factory: %{name: name, message: message}}) do
    "#{name} factory failed while building #{inspect(message)}. #{inspect(field)} is required."
  end

  def message(%{reason: :required_field, data: fields, factory: %{name: name, message: message}}) do
    "#{name} factory failed while building #{inspect(message)}. #{inspect(fields)} are required."
  end

  def message(%{reason: reason, factory: %{name: name, message: message}}) do
    "#{name} factory failed while building #{inspect(message)}. #{reason}"
  end
end
