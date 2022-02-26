defmodule Blunt.Absinthe.Type do
  @moduledoc false

  def from_message_field(message_module, {name, :map, _field_opts}, opts) do
    operation = Keyword.fetch!(opts, :operation)
    field_name = Keyword.fetch!(opts, :field_name)

    error_message =
      "#{operation} field `#{field_name}` -- from module `#{inspect(message_module)}` -- requires an arg_types mapping for the argument '#{name}'"

    option_configured_type_mapping(name, opts) ||
      app_configured_type_mapping(:map) ||
      raise Blunt.Absinthe.Error, message: error_message
  end

  def from_message_field(message_module, {name, {:array, type}, _field_opts}, opts) do
    type = from_message_field(message_module, {name, type, nil}, opts)
    quote do: list_of(unquote(type))
  end

  def from_message_field(message_module, {name, Ecto.Enum, field_opts}, opts) do
    from_message_field(message_module, {name, :enum, field_opts}, opts)
  end

  def from_message_field(message_module, {name, :enum, _field_opts}, opts) do
    operation = Keyword.fetch!(opts, :operation)
    field_name = Keyword.fetch!(opts, :field_name)

    error_message =
      "#{operation} field '#{field_name}' -- from module '#{inspect(message_module)}' -- requires an arg_types mapping for the argument '#{name}'"

    enum_type = option_configured_type_mapping(name, opts) || raise Blunt.Absinthe.Error, message: error_message

    quote do: unquote(enum_type)
  end

  def from_message_field(_message_module, {_name, :binary_id, _field_opts}, _opts), do: quote(do: :id)
  def from_message_field(_message_module, {_name, :utc_datetime, _field_opts}, _opts), do: quote(do: :datetime)

  def from_message_field(_message_module, {name, type, _field_opts}, opts) do
    type =
      option_configured_type_mapping(name, opts) ||
        app_configured_type_mapping(type) ||
        type

    quote do: unquote(type)
  end

  defp app_configured_type_mapping(type) do
    :blunt
    |> Application.get_env(:absinthe, [])
    |> Keyword.get(:type_mappings, [])
    |> Keyword.get(type)
  end

  def option_configured_type_mapping(name, opts) do
    opts
    |> Keyword.get(:arg_types, [])
    |> Keyword.get(name)
  end
end
