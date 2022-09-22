defmodule Blunt.Test.FieldTypes.EmailField do
  use Blunt.Message.Schema.FieldDefinition

  @impl true
  def define(:email, opts) do
    {:string, opts}
  end

  @impl true
  def define(__MODULE__, opts) do
    {:string, opts}
  end

  def fake(__MODULE__) do
    "fake_hombre@example.com"
  end

  def fake(:email) do
    "fake_hombre@example.com"
  end

  # @behaviour Blunt.Message.Schema.FieldProvider

  # @field_types [:email, __MODULE__]

  # alias Ecto.Changeset
  # alias Blunt.Message.Schema

  # @impl true
  # def ecto_field(module, {field_name, field_type, opts}) when field_type in @field_types do
  #   quote bind_quoted: [module: module, field_name: field_name, opts: opts] do
  #     Schema.put_field_validation(module, field_name, :email)
  #     Ecto.Schema.field(field_name, :string, opts)
  #   end
  # end

  # @impl true
  # def validate_changeset(:email, field_name, changeset, _module) do
  #   Changeset.validate_format(changeset, field_name, ~r/@/)
  # end

  # @impl true
  # def fake(field_type, _validation, _field_config) when field_type in @field_types do
  #   "fake_hombre@example.com"
  # end
end
