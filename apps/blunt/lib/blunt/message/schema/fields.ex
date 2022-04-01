defmodule Blunt.Message.Schema.Fields do
  @moduledoc false
  alias Blunt.Message.Schema
  alias Blunt.Message.Schema.FieldDefinition

  def record(name, type, opts \\ []) do
    quote bind_quoted: [name: name, type: type, opts: opts] do
      internal = Keyword.get(opts, :internal, false)
      required = internal == false and Keyword.get(opts, :required, @require_all_fields?)

      validation_name = Keyword.get(opts, :validate)
      Schema.put_field_validation(__MODULE__, name, validation_name)

      opts =
        [default: nil]
        |> Keyword.merge(opts)
        |> Keyword.put(:required, required)
        |> Keyword.put_new(:internal, false)

      if required do
        @required_fields name
      end

      {type, opts} = FieldDefinition.find_field_definition(type, opts)

      @schema_fields {name, type, opts}
    end
  end

  def internal_field_names(fields) do
    fields
    |> Enum.filter(fn {_name, _type, config} -> Keyword.fetch!(config, :internal) == true end)
    |> Enum.map(&elem(&1, 0))
  end

  def embedded?(module) do
    case Code.ensure_compiled(module) do
      {:module, module} -> function_exported?(module, :__schema__, 2)
      _ -> false
    end
  end
end
