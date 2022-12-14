defmodule Blunt.Message.TypeSpec do
  @moduledoc false

  alias Blunt.Message.Schema.Fields
  alias Blunt.Message.TypeSpec.Provider, as: TypeSpecProvider

  defmacro __using__(_opts) do
    quote do
      @before_compile Blunt.Message.TypeSpec
    end
  end

  defmacro __before_compile__(%{module: module}) do
    types =
      module
      |> Module.get_attribute(:schema_fields)
      |> Enum.map(&field_type/1)
      |> Enum.reject(&is_nil/1)

    quote do
      @type t :: %unquote(module){unquote_splicing(types)}
    end
  end

  defp field_type({name, :any, opts}), do: {name, field_type_spec(quote(do: any()), opts)}
  defp field_type({name, :atom, opts}), do: {name, field_type_spec(quote(do: atom()), opts)}
  defp field_type({name, :binary_id, opts}), do: {name, field_type_spec(quote(do: binary()), opts)}
  defp field_type({name, :boolean, opts}), do: {name, field_type_spec(quote(do: boolean()), opts)}
  defp field_type({name, :date, opts}), do: {name, field_type_spec(quote(do: Date.t()), opts)}
  defp field_type({name, :decimal, opts}), do: {name, field_type_spec(quote(do: float()), opts)}
  defp field_type({name, :enum, opts}), do: {name, enum_values(opts)}
  defp field_type({name, :float, opts}), do: {name, field_type_spec(quote(do: float()), opts)}
  defp field_type({name, :integer, opts}), do: {name, field_type_spec(quote(do: integer()), opts)}
  defp field_type({name, :map, opts}), do: {name, field_type_spec(quote(do: map()), opts)}
  defp field_type({name, :pid, opts}), do: {name, field_type_spec(quote(do: pid()), opts)}
  defp field_type({name, :string, opts}), do: {name, field_type_spec(quote(do: String.t()), opts)}
  defp field_type({name, Blunt.Message.Type.Atom, opts}), do: {name, field_type_spec(quote(do: atom()), opts)}
  defp field_type({name, Blunt.Message.Type.Pid, opts}), do: {name, field_type_spec(quote(do: pid()), opts)}
  defp field_type({name, Ecto.Enum, opts}), do: {name, enum_values(opts)}
  defp field_type({name, Ecto.UUID, opts}), do: {name, field_type_spec(quote(do: binary()), opts)}

  defp field_type({name, {:array, type}, opts}) do
    inner_type_opts = Keyword.put(opts, :required, true)

    case field_type({name, type, inner_type_opts}) do
      nil ->
        nil

      {name, type} ->
        {name, field_type_spec([type], opts)}
    end
  end

  defp field_type({name, type, _opts} = field_definition) do
    if Fields.embedded?(type) do
      {name, quote(do: unquote(type).t())}
    else
      TypeSpecProvider.provide(field_definition)
    end
  end

  defp field_type_spec(quoted_type, opts) do
    case Keyword.get(opts, :required) do
      true ->
        quoted_type

      false ->
        quote do
          unquote(quoted_type) | nil
        end
    end
  end

  defp enum_values(opts) do
    values = Keyword.fetch!(opts, :values) |> Enum.sort()

    values =
      case Keyword.get(opts, :required) do
        true -> values
        false -> values ++ [nil]
      end

    union_type_ast(values)
  end

  def union_type_ast([value]), do: value
  def union_type_ast([value | values]), do: {:|, [], [value, union_type_ast(values)]}
end
