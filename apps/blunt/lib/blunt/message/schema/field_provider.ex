defmodule Blunt.Message.Schema.FieldProvider do
  @moduledoc """
    Behaviour to define custom field types and validations
  """

  @type field_name :: atom()
  @type field_type :: atom()
  @type validation :: atom()
  @type message_module :: atom()
  @type field_definition :: {name :: atom, type :: any(), opts :: keyword()}

  @callback ecto_field(message_module(), field_definition()) :: term()

  @type changeset :: Ecto.Changeset.t()
  @callback validate_changeset(validation(), field_name(), changeset(), message_module()) :: changeset()

  @callback fake(field_type(), validation(), keyword()) :: any()

  defmodule Error do
    defexception [:message]
  end

  alias Blunt.Config

  @doc false
  def ecto_field(module, field_definition, opts \\ []) do
    providers = Config.schema_field_providers(opts)

    Enum.reduce_while(providers, nil, fn provider, _acc ->
      attempt_ecto_field(module, provider, field_definition)
    end)
  end

  defp attempt_ecto_field(module, provider, field_definition) do
    try do
      field = provider.ecto_field(module, field_definition)

      if field,
        do: {:halt, field},
        else: {:cont, nil}
    rescue
      FunctionClauseError ->
        {:cont, nil}
    end
  end

  @doc false
  def fake(type, config, opts \\ []) do
    providers = Config.schema_field_providers(opts)

    Enum.reduce_while(providers, nil, fn provider, _acc ->
      attempt_fake(provider, type, config, opts)
    end)
  end

  defp attempt_fake(provider, type, config, opts) do
    try do
      validation = Keyword.get(opts, :validation, :none)
      field = provider.fake(type, validation, config)

      if field,
        do: {:halt, field},
        else: {:cont, nil}
    rescue
      FunctionClauseError ->
        {:cont, nil}
    end
  end

  @doc false
  def validate_field({name, validation}, changeset, message_module, opts \\ []) do
    providers = Config.schema_field_providers(opts)

    Enum.reduce_while(providers, changeset, fn provider, changeset ->
      attempt_validate(provider, validation, name, changeset, message_module)
    end)
  end

  defp attempt_validate(provider, validation, name, changeset, message_module) do
    try do
      changeset = provider.validate_changeset(validation, name, changeset, message_module)
      {:halt, changeset}
    rescue
      FunctionClauseError ->
        {:cont, changeset}
    end
  end
end
