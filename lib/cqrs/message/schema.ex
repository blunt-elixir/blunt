defmodule Cqrs.Message.Schema do
  @moduledoc false

  defmacro generate do
    quote do
      use Ecto.Schema

      alias Cqrs.Message.{Field, MessageType}

      if Module.get_attribute(__MODULE__, :create_jason_encoders?) and Code.ensure_loaded?(Jason),
        do: @derive({Jason.Encoder, except: [:discarded_input]})

      if Mix.env() == :prod do
        @derive {Inspect, except: [:discarded_input]}
      end

      @primary_key false
      embedded_schema do
        Ecto.Schema.field(:discarded_input, :map, virtual: true)

        Enum.map(@schema_fields, fn
          {name, {:array, :enum}, opts} ->
            Ecto.Schema.field(name, {:array, Ecto.Enum}, opts)

          {name, {:array, type}, opts} ->
            if Field.embedded?(type),
              do: Ecto.Schema.embeds_many(name, type),
              else: Ecto.Schema.field(name, {:array, type}, opts)

          {name, :enum, opts} ->
            Ecto.Schema.field(name, Ecto.Enum, opts)

          {name, :binary_id, opts} ->
            Ecto.Schema.field(name, Ecto.UUID, opts)

          {name, type, opts} ->
            if Field.embedded?(type),
              do: Ecto.Schema.embeds_one(name, type),
              else: Ecto.Schema.field(name, type, opts)
        end)
      end
    end
  end
end
