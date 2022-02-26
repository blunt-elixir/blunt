defmodule Blunt.Context.Proxy do
  @moduledoc false

  alias Blunt.Message.{Input, Metadata}
  alias Blunt.Context.{Error, Proxy}

  def validate!({:command, command_module, _function_name}, context_module) do
    error = "#{inspect(command_module)} in #{inspect(context_module)} is not a valid #{inspect(Blunt.Command)}."
    do_validate!(command_module, :command, error)
  end

  def validate!({:query, query_module, _function_name}, context_module) do
    error = "#{inspect(query_module)} in #{inspect(context_module)} is not a valid #{inspect(Blunt.Query)}."
    do_validate!(query_module, :query, error)
  end

  defp do_validate!(message_module, type, error) do
    case Code.ensure_compiled(message_module) do
      {:module, module} ->
        unless Metadata.is_message_type?(module, type) do
          raise Error, message: error
        end

      _ ->
        raise Error, message: error
    end
  end

  def generate({:command, command_module, proxy_opts}) do
    moduledoc = docs(command_module)
    {function_name, proxy_opts} = function_name(command_module, proxy_opts)

    quote do
      @doc unquote(moduledoc)
      def unquote(function_name)(values, opts \\ []) do
        Proxy.dispatch(unquote(command_module), values, unquote(proxy_opts), opts)
      end
    end
  end

  def generate({:query, query_module, proxy_opts}) do
    moduledoc = docs(query_module)
    {function_name, proxy_opts} = function_name(query_module, proxy_opts)
    query_function_name = String.to_atom("#{function_name}_query")

    quote do
      @doc unquote(moduledoc)
      def unquote(function_name)(values \\ [], opts \\ []) do
        Proxy.dispatch(unquote(query_module), values, unquote(proxy_opts), opts)
      end

      @doc "Same as `#{unquote(function_name)}` but returns the query without executing it"
      def unquote(query_function_name)(values, opts \\ []) do
        Proxy.dispatch(unquote(query_module), values, unquote(proxy_opts), opts, return: :query)
      end
    end
  end

  def docs(module) do
    if function_exported?(module, :__doc__, 1) do
      shortdoc = module.__doc__(:short)
      fielddoc = module.__doc__(:field)
      optiondoc = module.__doc__(:option)

      shortdoc <> fielddoc <> optiondoc
    end
  end

  def function_name(message_module, opts) do
    {as, opts} = Keyword.pop(opts, :as)

    name =
      case as do
        nil ->
          [name | _] =
            message_module
            |> Module.split()
            |> Enum.reverse()

          name
          |> to_string
          |> Macro.underscore()
          |> String.to_atom()

        name ->
          name
      end

    {name, opts}
  end

  def dispatch(message_module, values, proxy_opts, dispatch_opts, internal_opts \\ []) do
    {field_values, opts} =
      dispatch_opts
      |> Keyword.merge(proxy_opts)
      |> Keyword.merge(internal_opts)
      |> Keyword.put(:dispatched_from, :bounded_context)
      |> Keyword.put(:user_supplied_fields, user_supplied_fields(values))
      |> Keyword.pop(:field_values, [])

    field_values = Enum.into(field_values, %{})
    values = Input.normalize(values, message_module)

    values
    |> Map.merge(field_values)
    |> message_module.new()
    |> message_module.dispatch(opts)
  end

  defp user_supplied_fields(list) when is_list(list),
    do: Keyword.keys(list)

  defp user_supplied_fields(struct) when is_struct(struct),
    do: user_supplied_fields(Map.from_struct(struct))

  defp user_supplied_fields(map) when is_map(map),
    do: Map.keys(map)
end
