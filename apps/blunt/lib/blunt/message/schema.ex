defmodule Blunt.Message.Schema do
  @moduledoc false

  alias Blunt.Config
  alias Blunt.Message.Schema.FieldProvider

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

  def put_field_validation(module, field_name, validation_name) do
    if validation_name,
      do: Module.put_attribute(module, :schema_field_validations, {field_name, validation_name})
  end

  def generate(%{module: module}) do
    schema_fields =
      module
      |> Module.get_attribute(:schema_fields)
      |> Enum.map(fn {name, type, opts} -> {name, type, Macro.escape(opts)} end)

    jason_encoder? = Module.get_attribute(module, :create_jason_encoders?) and Code.ensure_loaded?(Jason)

    fields = Enum.map(schema_fields, &FieldProvider.ecto_field(module, &1))

    quote do
      use Ecto.Schema

      if unquote(jason_encoder?) do
        @derive Jason.Encoder
      end

      if Mix.env() == :prod do
        @derive Inspect
      end

      @primary_key false
      embedded_schema do
        unquote(fields)
      end

      @metadata built_in_validations: @built_in_validations
      @metadata field_validations: @schema_field_validations
    end
  end
end
