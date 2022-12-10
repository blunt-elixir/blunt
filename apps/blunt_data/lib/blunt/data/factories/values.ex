defmodule Blunt.Data.Factories.Values do
  alias Blunt.Data.Factories.Values

  @doc """
  The `field` of the factory source data will be assigned
  to the value
  """
  defmacro const(field, value) do
    quote do
      %Values.Constant{field: unquote(field), value: unquote(value)}
    end
  end

  @doc """
  If the `field` is not supplied to the factory,
  the given `message` will be dispatched with the returned
  data to be put into the factory source data under the `field` key.
  """
  defmacro data(field, message) do
    create_data(field, message, [], lazy: false)
  end

  defmacro data(field, message, do: body) do
    values = extract_values(body)
    create_data(field, message, values, lazy: false)
  end

  defmacro data(field, message, opts \\ [], do: body) do
    values = extract_values(body)
    opts = Keyword.put(opts, :lazy, false)
    create_data(field, message, values, opts)
  end

  @doc """
  Same as `data` but
  """
  defmacro lazy_data(field, message) do
    create_data(field, message, [], lazy: true)
  end

  defmacro lazy_data(field, message, do: body) do
    values = extract_values(body)
    create_data(field, message, values, lazy: true)
  end

  defmacro lazy_data(field, message, opts \\ [], do: body) do
    values = extract_values(body)
    opts = Keyword.put(opts, :lazy, true)
    create_data(field, message, values, opts)
  end

  defp extract_values({:__block__, _meta, elements}), do: elements
  defp extract_values(nil), do: []
  defp extract_values(list) when is_list(list), do: list
  defp extract_values(element), do: [element]

  defp create_data(field, message, values, opts) do
    {lazy, opts} = Keyword.pop!(opts, :lazy)
    {operation, message, values} = data_props(message, values)

    quote do
      %Values.Data{
        lazy: unquote(lazy),
        field: unquote(field),
        factory: %{
          values: unquote(values),
          message: unquote(message),
          operation: unquote(operation),
          opts: unquote(opts)
        }
      }
    end
  end

  defp data_props(message, values) do
    case message do
      {operation, {message, values}} -> {operation, message, values}
      {operation, message} -> {operation, message, values}
      message -> {:dispatch, message, values}
    end
  end

  @doc """

  The `field` of the factory source data will be assigned
  to the value of `path_func_or_value` in the factory source

  ## Options
  * **prefix** *atom* | *string*
    If this option is set, the resulting keys in the factory data will be prefixed
    with this value
  """

  defmacro merge_prop(field, path_func_or_value, opts \\ []) do
    {prefix, opts} = Keyword.pop(opts, :prefix)

    opts =
      opts
      |> Keyword.put(:merge_prefix, prefix)
      |> Keyword.put(:merge, true)

    quote do
      %Values.Prop{field: unquote(field), path_func_or_value: unquote(path_func_or_value), opts: unquote(opts)}
    end
  end

  @doc """
  The `field` of the factory source data will be assigned
  to the value of `path_func_or_value` in the factory source

  ## Options

  * **merge** *boolean*

    If `true`, the results of prop will be merged into the current factory's data. If `false`,
    the the results of the will be in the factory's data under key matching the name of the prop.

  * **merge_prefix** *atom* | *string*

    Only used in conjunction with `merge`.

    If merge is true and this option is set, the resulting keys in the factory data will be prefixed
    with this value
  """
  defmacro prop(field, path_func_or_value, opts \\ []) do
    quote do
      %Values.Prop{field: unquote(field), path_func_or_value: unquote(path_func_or_value), opts: unquote(opts)}
    end
  end

  @doc """
  The `field` of the factory source data will be assigned
  to the value of `path_func_or_value` in the factory source
  """
  defmacro lazy_prop(field, path_func_or_value) do
    quote do
      %Values.Prop{field: unquote(field), path_func_or_value: unquote(path_func_or_value), lazy: true}
    end
  end

  @doc """
  Merges a key from input into the current factory data.

  This will not overwrite any existing data.
  """
  defmacro merge_input(key, opts \\ []) do
    quote do
      %Values.MergeInput{key: unquote(key), opts: unquote(opts)}
    end
  end

  defmacro map(func) do
    quote do
      %Values.Mapper{func: unquote(func)}
    end
  end

  defmacro child(field, factory_name) do
    quote do
      %Values.Build{field: unquote(field), factory_name: unquote(factory_name)}
    end
  end

  defmacro defaults(values) do
    quote do
      %Values.Defaults{values: Enum.into(unquote(values), %{})}
    end
  end

  defmacro required_prop(field_or_fields) when is_atom(field_or_fields) or is_list(field_or_fields) do
    quote do
      %Values.RequiredProp{fields: List.wrap(unquote(field_or_fields))}
    end
  end

  defmacro required_props(fields) when is_list(fields) do
    quote do
      %Values.RequiredProp{fields: unquote(fields)}
    end
  end

  defmacro remove(fields) when is_atom(fields) or is_list(fields) do
    fields = List.wrap(fields)

    quote do
      %Values.RemoveProp{fields: unquote(fields)}
    end
  end

  defmacro input(props) when is_list(props) do
    quote do
      %Values.Input{props: unquote(props)}
    end
  end

  defmacro inspect_props(:declared) do
    quote do
      %Values.InspectProps{props: :declared}
    end
  end

  defmacro inspect_props(props) when is_list(props) do
    quote do
      %Values.InspectProps{props: unquote(props)}
    end
  end

  defmacro inspect_props do
    quote do
      %Values.InspectProps{props: :all}
    end
  end
end
