defmodule Cqrs.Command.Events do
  @moduledoc false

  def record(name, opts) do
    quote do
      @events {unquote(name), unquote(opts), {__ENV__.file, __ENV__.line}}
    end
  end

  def generate_events(%{module: command} = env),
    do: Enum.each(command.__events__(), &generate_event(env, &1))

  defp generate_event(%{module: command} = env, {event_name, opts, {file, line}}) do
    event_body = Keyword.get(opts, :do, nil)
    to_drop = Keyword.get(opts, :drop, []) |> List.wrap()

    schema_fields =
      command.__schema_fields__()
      |> Enum.reject(fn {name, _type, _opts} -> Enum.member?(to_drop, name) end)
      |> Enum.map(fn
        {:created_at, _, _} -> nil
        {name, type, opts} -> quote do: field(unquote(name), unquote(type), unquote(opts))
      end)

    domain_event =
      quote do
        use Cqrs.DomainEvent
        unquote_splicing(schema_fields)
        Module.eval_quoted(__MODULE__, unquote(event_body))
      end

    env =
      env
      |> Map.put(:file, file)
      |> Map.put(:line, line)

    command
    |> fq_event_name(event_name, opts)
    |> Module.create(domain_event, env)
  end

  @doc false
  def fq_event_name(command, event_name, opts) do
    case Keyword.get(opts, :ns) do
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
