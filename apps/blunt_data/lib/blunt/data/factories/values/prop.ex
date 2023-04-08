defmodule Blunt.Data.Factories.Values.Prop do
  @moduledoc false
  @derive {Inspect, except: [:lazy]}
  defstruct [:field, :path_func_or_value, opts: [], lazy: false]

  alias Blunt.Data.FactoryError
  alias Blunt.Data.Factories.Factory
  alias Blunt.Data.Factories.Values.Prop

  defimpl Blunt.Data.Factories.Value do
    def declared_props(%Prop{field: field}), do: [field]

    def error(%Prop{field: field}, error, current_factory),
      do: raise(Blunt.Data.Factories.ValueError, factory: current_factory, error: error, prop: field)

    def evaluate(%Prop{field: field, path_func_or_value: path, lazy: lazy, opts: opts}, acc, current_factory)
        when is_list(path) do
      if not lazy or (lazy and not Map.has_key?(acc, field)) do
        case path do
          [] ->
            value = Factory.log_value(current_factory, [], field, lazy, "prop")
            put_values(acc, field, value, opts)

          [head | rest] ->
            # ensure that the first key in the path is not nil
            acc =
              Map.update(acc, head, %{}, fn
                nil -> %{}
                other -> other
              end)

            keys = [Access.key(head, %{}) | Enum.map(rest, &Access.key/1)]
            value = get_in(acc, keys)
            value = Factory.log_value(current_factory, value, field, lazy, "prop")
            put_values(acc, field, value, opts)
        end
      else
        acc
      end
    end

    def evaluate(%Prop{field: field, path_func_or_value: func, lazy: lazy, opts: opts}, acc, current_factory)
        when is_function(func, 0) do
      if not lazy or (lazy and not Map.has_key?(acc, field)) do
        value =
          case func.() do
            {:ok, result} ->
              result

            {:error, error} ->
              raise FactoryError, reason: error, factory: current_factory

            results when is_list(results) ->
              Enum.map(results, fn
                {:ok, result} ->
                  result

                {:error, error} ->
                  raise FactoryError, reason: error, factory: current_factory

                other ->
                  other
              end)

            result ->
              result
          end

        value = Factory.log_value(current_factory, value, field, lazy, "prop")
        put_values(acc, field, value, opts)
      else
        acc
      end
    end

    def evaluate(%Prop{field: field, path_func_or_value: func, lazy: lazy, opts: opts}, acc, current_factory)
        when is_function(func, 1) do
      if not lazy or (lazy and not Map.has_key?(acc, field)) do
        value =
          case func.(acc) do
            {:ok, result} ->
              result

            {:error, error} ->
              raise FactoryError, reason: error, factory: current_factory

            results when is_list(results) ->
              Enum.map(results, fn
                {:ok, result} ->
                  result

                {:error, error} ->
                  raise FactoryError, reason: error, factory: current_factory

                other ->
                  other
              end)

            result ->
              result
          end

        value = Factory.log_value(current_factory, value, field, lazy, "prop")
        put_values(acc, field, value, opts)
      else
        acc
      end
    end

    def evaluate(%Prop{field: field, path_func_or_value: value, lazy: lazy, opts: opts}, acc, current_factory) do
      if not lazy or (lazy and not Map.has_key?(acc, field)) do
        value = Factory.log_value(current_factory, value, field, lazy, "prop")
        put_values(acc, field, value, opts)
      else
        acc
      end
    end

    defp put_values(factory_data, prop, value, opts) do
      if Keyword.get(opts, :merge, false) do
        merge_data(factory_data, value, opts)
      else
        Map.put(factory_data, prop, value)
      end
    end

    defp merge_data(factory_data, value, opts) do
      case Keyword.get(opts, :merge_prefix) do
        nil ->
          Map.merge(factory_data, value)

        prefix ->
          Enum.reduce(value, factory_data, fn
            {key, value}, acc -> Map.put(acc, :"#{prefix}_#{key}", value)
            _, acc -> acc
          end)
      end
    end
  end
end
