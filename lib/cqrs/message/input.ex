defmodule Cqrs.Message.Input do
  @moduledoc false

  @type t :: map() | struct() | keyword()

  require Logger
  require Decimal

  def normalize(values, message) when is_list(values) do
    cond do
      Keyword.keyword?(values) ->
        normalize(Enum.into(values, %{}), message)

      true ->
        Logger.warn("values are expected to be a keyword list")
        normalize(%{}, message)
    end
  end

  def normalize(values, message) when is_struct(values),
    do: normalize(Map.from_struct(values), message)

  def normalize(values, message) when is_map(values) do
    values
    |> normalize_maps()
    |> populate_from_sources(message)
  end

  defp normalize_maps(list) when is_list(list),
    do: Enum.map(list, &normalize_maps/1)

  defp normalize_maps(map) when is_map(map) do
    Enum.into(map, %{}, fn
      {key, %Date{} = value} ->
        {to_string(key), value}

      {key, %DateTime{} = value} ->
        {to_string(key), value}

      {key, %NaiveDateTime{} = value} ->
        {to_string(key), value}

      {key, value} when Decimal.is_decimal(value) ->
        {to_string(key), Decimal.to_float(value)}

      {key, value} when is_struct(value) ->
        {to_string(key), normalize_maps(Map.from_struct(value))}

      {key, value} when is_map(value) ->
        {to_string(key), normalize_maps(value)}

      {key, value} ->
        {to_string(key), value}
    end)
  end

  defp normalize_maps(other), do: other

  defp populate_from_sources(values, message) do
    Enum.reduce(message.__schema__(:fields), values, fn field, acc ->
      field_source = message.__schema__(:field_source, field)
      source_value = Map.get(values, field_source)

      acc =
        case source_value do
          nil ->
            acc

          value ->
            Map.update(acc, to_string(field), value, fn
              nil -> value
              other -> other
            end)
        end

      Map.delete(acc, field_source)
    end)
  end
end
