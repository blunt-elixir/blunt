defmodule Support.Message.Schema.EmailFieldProvider do
  @moduledoc """
  Defines a `email` field type for usage in a Blunt message
  """

  # @field_types [:email, __MODULE__]

  # alias Ecto.Changeset
  # alias Blunt.Message.Schema

  use Blunt.Message.Schema.FieldDefinition

  @impl true
  def define(:email, opts) do
    {:string, opts}
  end

  @impl true
  def fake(:email) do
    "fake_hombre@example.com"
  end

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

  # def validate_changeset(:begin_with_capital_letter, field_name, changeset, _mod) do
  #   Changeset.validate_format(changeset, field_name, ~r/^[A-Z]{1}.+/, message: "must begin with a capital letter")
  # end

  # @impl true
  # def fake(field_type, _validation, _field_config) when field_type in @field_types do
  #   send(self(), :email_field_faked)
  #   "fake_hombre@example.com"
  # end

  # def fake(_field_type, :begin_with_capital_letter, _field_config) do
  #   send(self(), :begin_with_capital_letter_validation_field_faked)
  #   "Chris"
  # end
end
