defmodule Cqrs.Message.Schema do
  @moduledoc false

  alias Cqrs.Config
  alias Cqrs.Message.Schema.Fields

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

  def generate(%{module: module}) do
    schema_fields =
      module
      |> Module.get_attribute(:schema_fields)
      |> Macro.escape()

    jason_encoder? = Module.get_attribute(module, :create_jason_encoders?) and Code.ensure_loaded?(Jason)

    quote bind_quoted: [schema_fields: schema_fields, jason_encoder?: jason_encoder?] do
      use Ecto.Schema

      if jason_encoder? do
        @derive Jason.Encoder
      end

      if Mix.env() == :prod do
        @derive Inspect
      end

      @primary_key false
      embedded_schema do
        Enum.map(schema_fields, fn
          {name, {:array, :enum}, opts} ->
            Ecto.Schema.field(name, {:array, Ecto.Enum}, opts)

          {name, {:array, type}, opts} ->
            if Fields.embedded?(type),
              do: Ecto.Schema.embeds_many(name, type),
              else: Ecto.Schema.field(name, {:array, type}, opts)

          {name, :enum, opts} ->
            Ecto.Schema.field(name, Ecto.Enum, opts)

          {name, :binary_id, opts} ->
            Ecto.Schema.field(name, Ecto.UUID, opts)

          {name, type, opts} ->
            if Fields.embedded?(type),
              do: Ecto.Schema.embeds_one(name, type),
              else: Ecto.Schema.field(name, type, opts)
        end)
      end
    end
  end
end
