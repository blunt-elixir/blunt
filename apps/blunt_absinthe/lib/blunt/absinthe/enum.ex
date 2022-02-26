defmodule Blunt.Absinthe.Enum do
  @moduledoc false
  alias Blunt.Absinthe.Error

  def generate_type(enum_name, {enum_source_module, field_name}) do
    values =
      case enum_values(enum_source_module, field_name) do
        [] ->
          raise Error, message: "#{inspect(enum_source_module)}.#{field_name} is not a valid enum type"

        values ->
          Enum.map(values, fn enum_value -> quote do: value(unquote(enum_value)) end)
      end

    quote do
      enum unquote(enum_name) do
        (unquote_splicing(values))
      end
    end
  end

  defp enum_values(module, field_name) do
    case module.__schema__(:type, field_name) do
      {:parameterized, Ecto.Enum, opts} -> read_enum_values(opts)
      {:array, {:parameterized, Ecto.Enum, opts}} -> read_enum_values(opts)
      _ -> []
    end
  end

  defp read_enum_values(opts) do
    from_mappings =
      opts
      |> Map.get(:mappings, [])
      |> Keyword.keys()

    from_values = Map.get(opts, :values, [])

    from_mappings ++ from_values
  end
end
