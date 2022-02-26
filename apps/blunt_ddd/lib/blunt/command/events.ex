defmodule Blunt.Command.Events do
  @moduledoc false

  alias Blunt.Command.Events
  alias Blunt.Message.Metadata

  def record(name, opts) do
    quote do
      @events {unquote(name), unquote(opts), {__ENV__.file, __ENV__.line}}
    end
  end

  def generate_proxy({name, opts, {file, line}}) do
    opts = Keyword.delete(opts, :do)

    event_name =
      name
      |> Module.split()
      |> List.last()

    proxy_function_name = String.to_atom(Macro.underscore(event_name))

    event_module =
      quote bind_quoted: [name: name, opts: opts] do
        Events.fq_event_name(__MODULE__, name, opts)
      end

    quote file: file, line: line do
      def unquote(proxy_function_name)(command, values \\ []) do
        Events.proxy_dispatch(__MODULE__, unquote(event_module), command, values)
      end
    end
  end

  def proxy_dispatch(_command_module, _event_module, {:error, _} = errors, _values),
    do: errors

  def proxy_dispatch(command_module, event_module, {:ok, %{__struct__: command_module} = command, _}, values),
    do: event_module.new(command, values)

  def proxy_dispatch(command_module, event_module, %{__struct__: command_module} = command, values),
    do: event_module.new(command, values)

  def generate_events(%{module: command} = env),
    do: Enum.each(command.__events__(), &generate_event(env, &1))

  defp generate_event(%{module: command} = env, {__name, opts, {file, line}} = event) do
    event_body = Keyword.get(opts, :do, nil)
    to_drop = Keyword.get(opts, :drop, []) |> List.wrap()

    schema_fields =
      command
      |> Metadata.fields()
      |> Enum.reject(fn {name, _type, _opts} -> Enum.member?(to_drop, name) end)
      |> Enum.map(fn
        {:created_at, _, _} -> nil
        {name, type, opts} -> quote do: field(unquote(name), unquote(type), unquote(opts))
      end)

    module_name = fq_event_name(command, event)

    domain_event =
      quote do
        use Blunt.DomainEvent
        unquote_splicing(schema_fields)
        Module.eval_quoted(__MODULE__, unquote(event_body))
      end

    env =
      env
      |> Map.put(:file, file)
      |> Map.put(:line, line)

    Module.create(module_name, domain_event, env)
  end

  def fq_event_name(command, {event_name, event_opts, _location}),
    do: fq_event_name(command, event_name, event_opts)

  @doc false
  def fq_event_name(command, event_name, event_opts) do
    case Keyword.get(event_opts, :ns) do
      nil ->
        case namespace(event_name) do
          Elixir -> command |> namespace() |> Module.concat(event_name)
          _ns -> event_name
        end

      ns ->
        Module.concat(ns, event_name)
    end
  end

  defp namespace(module) do
    [_module_name | namespace] =
      module
      |> Module.split()
      |> Enum.reverse()

    namespace
    |> Enum.reverse()
    |> Module.concat()
  end
end
