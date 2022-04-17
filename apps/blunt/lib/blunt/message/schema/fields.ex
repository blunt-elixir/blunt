defmodule Blunt.Message.Schema.Fields do
  @moduledoc false
  alias Blunt.Message.Schema
  alias Blunt.Message.Schema.FieldDefinition

  def record(name, type, opts \\ []) do
    quote bind_quoted: [name: name, type: type, opts: opts] do
      internal = Keyword.get(opts, :internal, false)
      default_not_defined? = Keyword.get(opts, :default) == nil
      required = default_not_defined? and internal == false and Keyword.get(opts, :required, @require_all_fields?)

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

  def field_names(fields) do
    Enum.map(fields, &elem(&1, 0))
  end

  def internal_field_names(fields) do
    fields
    |> Enum.filter(fn {_name, _type, config} -> Keyword.fetch!(config, :internal) == true end)
    |> field_names()
  end

  def virtual_field_names(fields) do
    fields
    |> Enum.filter(fn {_name, _type, config} -> Keyword.get(config, :virtual) == true end)
    |> field_names()
  end

  require Logger

  def embedded?(module) when is_atom(module) do
    embedded?(Atom.to_string(module))
  end

  def embedded?("Elixir." <> _ = module) do
    module = String.to_existing_atom(module)
    module = Code.ensure_compiled!(module)
    function_exported?(module, :__schema__, 2)
  end

  def embedded?(_module), do: false
end
