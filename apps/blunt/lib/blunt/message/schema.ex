defmodule Blunt.Message.Schema do
  @moduledoc false

  alias Blunt.Config
  alias Blunt.Message.Schema.Fields

  defmacro register(opts) do
    quote bind_quoted: [opts: opts] do
      create_jason_encoders? = Config.create_jason_encoders?(opts)
      Module.put_attribute(__MODULE__, :create_jason_encoders?, create_jason_encoders?)

      require_all_fields? = Keyword.get(opts, :require_all_fields?, false)
      Module.put_attribute(__MODULE__, :require_all_fields?, require_all_fields?)

      Module.register_attribute(__MODULE__, :schema_fields, accumulate: true)
      Module.register_attribute(__MODULE__, :required_fields, accumulate: true)
      Module.register_attribute(__MODULE__, :schema_field_validations, accumulate: true)
      Module.register_attribute(__MODULE__, :built_in_validations, accumulate: true)
    end
  end

  def require_at_least_one(fields) do
    quote do
      @built_in_validations {:require_at_least_one, unquote(fields)}
    end
  end

  def require_either(fields) do
    quote do
      @built_in_validations {:require_either, unquote(fields)}
    end
  end

  def put_field_validation(module, field_name, validation_name) do
    if validation_name,
      do: Module.put_attribute(module, :schema_field_validations, {field_name, validation_name})
  end

  def generate(%{module: module}) do
    schema_fields =
      module
      |> Module.get_attribute(:schema_fields)
      |> Macro.escape()

    jason_encoder? = Module.get_attribute(module, :create_jason_encoders?) and Code.ensure_loaded?(Jason)

    # fields = Enum.map(schema_fields, &FieldProvider.ecto_field(module, &1))

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
          {name, :binary_id, opts} ->
            Ecto.Schema.field(name, Ecto.UUID, opts)

          {name, :enum, opts} ->
            Ecto.Schema.field(name, Ecto.Enum, opts)

          {name, {:array, :enum}, opts} ->
            Ecto.Schema.field(name, {:array, Ecto.Enum}, opts)

          {name, {:array, type}, opts} ->
            if Fields.embedded?(type),
              do: Ecto.Schema.embeds_many(name, type),
              else: Ecto.Schema.field(name, {:array, type}, opts)

          {name, type, opts} ->
            if Fields.embedded?(type),
              do: Ecto.Schema.embeds_one(name, type),
              else: Ecto.Schema.field(name, type, opts)
        end)
      end

      @metadata built_in_validations: @built_in_validations
      @metadata field_validations: @schema_field_validations
    end
  end
end
