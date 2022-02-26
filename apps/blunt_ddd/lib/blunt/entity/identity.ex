defmodule Blunt.Entity.Identity do
  @moduledoc false

  @default {:id, Ecto.UUID, autogenerate: false}

  alias Blunt.Message.Metadata
  alias Blunt.{Behaviour, Entity.Error, Entity.Identity}

  def pop(opts) do
    opts
    |> Keyword.update(:identity, @default, &ensure_field/1)
    |> Keyword.pop!(:identity)
  end

  defp ensure_field({name, type}), do: {name, type, []}
  defp ensure_field({name, type, config}), do: {name, type, config}

  defp ensure_field(value) when value in [false, nil] do
    raise Error, message: "Entities require a primary key"
  end

  defp ensure_field(_other) do
    raise Error, message: "identity must be either {name, type} or {name, type, options}"
  end

  defmacro generate do
    quote do
      def identity(%__MODULE__{} = entity),
        do: Identity.identity(__MODULE__, entity)

      def equals?(left, right),
        do: Identity.equals?(__MODULE__, left, right)
    end
  end

  def identity(entity_module, entity) do
    Behaviour.validate!(entity_module, Blunt.Entity)
    {field_name, _type, _config} = Metadata.primary_key(entity_module)
    Map.fetch!(entity, field_name)
  end

  def equals?(entity_module, %{__struct__: entity_module} = left, %{__struct__: entity_module} = right) do
    identity(entity_module, left) == identity(entity_module, right)
  end

  def equals?(entity_module, _left, _right) do
    raise Error, message: "#{inspect(entity_module)}.equals? requires two #{inspect(entity_module)} structs"
  end
end
