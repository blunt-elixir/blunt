defmodule Blunt.Test.FieldTypes.UuidField do
  @behaviour Blunt.Message.Schema.FieldProvider

  @field_types [:uuid, __MODULE__]

  @impl true
  def ecto_field(module, {field_name, field_type, opts}) when field_type in @field_types do
    quote bind_quoted: [module: module, field_name: field_name, opts: opts] do
      Ecto.Schema.field(field_name, Ecto.UUID, opts)
    end
  end

  @impl true
  def validate_changeset(_field_type, _field_name, changeset, _module) do
    changeset
  end

  @impl true
  def fake(field_type, _validation, _field_config) when field_type in @field_types do
    UUID.uuid4()
  end
end
