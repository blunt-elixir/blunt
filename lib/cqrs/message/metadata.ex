defmodule Cqrs.Message.Metadata do
  def record(name, value) do
    quote do
      @metadata {unquote(name), unquote(value)}
    end
  end

  defmacro generate do
    quote do
      @metadata message_type: Module.delete_attribute(__MODULE__, :message_type)
      @metadata schema_fields: Module.delete_attribute(__MODULE__, :schema_fields)
      @metadata primary_key: Module.delete_attribute(__MODULE__, :primary_key_type)
    end
  end

  def message_type(module),
    do: fetch!(module, :message_type)

  def is_message_type?(module, type) when is_atom(module) and is_atom(type),
    do: message_type(module) == type

  def is_query?(module),
    do: is_message_type?(module, :query)

  def is_command?(module),
    do: is_message_type?(module, :command)

  def primary_key(module) do
    case fetch!(module, :primary_key) do
      {name, type, opts} -> {name, type, Keyword.put(opts, :required, true)}
      pk -> pk
    end
  end

  def has_field?(module, field_name) do
    names = field_names(module)
    Enum.member?(names, field_name)
  end

  def fields(module) do
    fetch!(module, :schema_fields)
  end

  def field_names(module) do
    module
    |> fields()
    |> Enum.map(&elem(&1, 0))
  end

  def required_fields(module) do
    module
    |> fields()
    |> Enum.filter(fn {_name, _type, opts} -> Keyword.fetch!(opts, :required) end)
    |> Enum.map(&elem(&1, 0))
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
