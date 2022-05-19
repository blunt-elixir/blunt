defmodule Blunt.Message.Schema.FieldDefinition do
  alias Blunt.Config

  @type custom_type :: atom()
  @type ecto_type :: atom() | module() | {:array, atom()} | {:array, module()}

  @callback define(custom_type, opts :: keyword()) :: {ecto_type, opts :: keyword()}

  defmacro __using__(_opts) do
    quote do
      @behaviour unquote(__MODULE__)
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def define(custom_type, opts), do: {custom_type, opts}
    end
  end

  def find_field_definition(type, opts) do
    definitions = Config.schema_field_definitions()

    custom_field_definition =
      Enum.reduce_while(definitions, nil, fn definition, _acc ->
        case definition.define(type, opts) do
          {^type, _} -> {:cont, nil}
          {ecto_type, opts} -> {:halt, {ecto_type, opts}}
        end
      end)

    with nil <- custom_field_definition do
      {type, opts}
    end
  end
end
