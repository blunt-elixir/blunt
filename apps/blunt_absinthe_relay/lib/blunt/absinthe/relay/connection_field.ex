defmodule Blunt.Absinthe.Relay.ConnectionField do
  @moduledoc false

  alias Absinthe.Relay.Connection

  alias Blunt.Absinthe.Relay.Config
  alias Blunt.DispatchContext, as: Context
  alias Blunt.Absinthe.{AbsintheErrors, Args, Field, Log}
  alias Blunt.Absinthe.Relay.ConnectionField

  def generate(query_module, node_type, opts) do
    repo = Config.get_repo!()
    field_name = Field.name(query_module, opts)

    opts =
      opts
      |> Keyword.put(:operation, :absinthe_relay_connection)
      |> Keyword.put(:field_name, field_name)
      |> Keyword.put(:message_module, query_module)

    args = Field.args(query_module, opts)
    description = Field.description(query_module)
    {before_resolve, after_resolve} = Field.middleware(opts)

    Blunt.Message.Compilation.log(query_module, "regenerated connection query #{field_name}")

    quote do
      connection field(unquote(field_name), node_type: unquote(node_type)) do
        unquote_splicing(args)
        description unquote(description)

        middleware unquote(before_resolve)

        resolve(fn parent, args, resolution ->
          ConnectionField.dispatch_and_resolve(
            unquote(query_module),
            unquote(opts),
            parent,
            args,
            unquote(repo)
          )
        end)

        middleware unquote(after_resolve)
      end
    end
  end

  @type resolution :: Absinthe.Resolution.t()
  @spec dispatch_and_resolve(atom, keyword, map, map, resolution) :: {:error, list} | {:ok, any}

  def dispatch_and_resolve(query_module, query_opts, parent, args, repo) do
    opts =
      query_opts
      |> Field.put_dispatch_opts(:absinthe_relay_connection, drop_connection_args(args))
      |> Keyword.put(:return, :query_context)

    results =
      args
      |> Args.resolve_message_input({query_module, parent, query_opts})
      |> query_module.new()
      |> query_module.dispatch(opts)

    :ok = Log.dump()

    case results do
      {:error, %Context{} = context} ->
        return_value = {:error, AbsintheErrors.from_dispatch_context(context)}

        context
        |> Context.put_pipeline(:absinthe_resolve, return_value)
        |> Context.Shipper.ship()

        return_value

      {:ok, %Context{} = context} ->
        query = Context.get_last_pipeline(context)

        repo_fun = fn args ->
          fun = Keyword.get(query_opts, :repo_fun, :all)
          apply(repo, fun, [args])
        end

        case Connection.from_query(query, repo_fun, args) do
          {:ok, results} ->
            results =
              results
              |> Map.put(:args, args)
              |> Map.put(:repo, repo)
              |> Map.put(:query, query)

            context
            |> Context.put_pipeline(:absinthe_resolve, results)
            |> Context.Shipper.ship()

            {:ok, results}

          {:error, error} ->
            context
            |> Context.put_pipeline(:absinthe_resolve, {:error, error})
            |> Context.Shipper.ship()

            {:error, error}
        end
    end
  end

  defp drop_connection_args(args),
    do: Map.drop(args, [:first, :after, :last, :before])
end
