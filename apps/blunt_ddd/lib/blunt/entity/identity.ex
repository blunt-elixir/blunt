defmodule Blunt.Entity.Identity do
  @moduledoc false

  require Logger

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

  def identity(module, entity) do
    Behaviour.validate!(module, Blunt.Entity)
    {field_name, _type, _config} = Metadata.primary_key(module)
    Map.fetch!(entity, field_name)
  end

  def equals?(_module, nil, _), do: false
  def equals?(_module, _, nil), do: false

  def equals?(module, %{__struct__: module} = left, %{__struct__: module} = right) do
    identity(module, left) == identity(module, right)
  end

  def equals?(module, _left, _right) do
    Logger.warn("#{inspect(module)}.equals? requires two #{inspect(module)} structs")
    false
  end
end
