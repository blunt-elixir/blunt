defmodule Cqrs.Message.Schema do
  @moduledoc false

  alias Cqrs.Config
  alias Cqrs.Message.Field

  defmacro register(opts) do
    quote bind_quoted: [opts: opts] do
      create_jason_encoders? = Config.create_jason_encoders?(opts)
      Module.put_attribute(__MODULE__, :create_jason_encoders?, create_jason_encoders?)

      require_all_fields? = Keyword.get(opts, :require_all_fields?, false)
      Module.put_attribute(__MODULE__, :require_all_fields?, require_all_fields?)

      Module.register_attribute(__MODULE__, :schema_fields, accumulate: true)
      Module.register_attribute(__MODULE__, :required_fields, accumulate: true)
    end
  end

  defmacro generate do
    quote do
      use Ecto.Schema

      alias Cqrs.Message.{Field, MessageType}

      if Module.get_attribute(__MODULE__, :create_jason_encoders?) and Code.ensure_loaded?(Jason) do
        @derive Jason.Encoder
      end

      if Mix.env() == :prod do
        @derive Inspect
      end

      @primary_key false
      embedded_schema do
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
