defmodule Cqrs.CustomDispatchStrategy do
  @behaviour Cqrs.DispatchStrategy

  alias Cqrs.Query
  alias Cqrs.DispatchContext, as: Context
  alias Cqrs.DispatchStrategy.HandlerResolver
  alias Cqrs.CustomDispatchStrategy.{CustomCommandHandler, CustomQueryHandler}

  @type context :: Context.t()
  @type query_context :: Context.query_context()
  @type command_context :: Context.command_context()

  @spec dispatch(command_context() | query_context()) ::
          {:error, context()} | {:ok, context() | any}

  @moduledoc """
  Receives a `DispatchContext`, locates the message handler, and runs the handler pipeline.

  ## CustomCommandHandler Pipeline

  1. `before_dispatch`
  2. `handle_authorize`
  3. `handle_dispatch`

  ## CustomQueryHandler Pipeline

  1. `before_dispatch`
  2. `create_query`
  3. `handle_scope`
  4. `handle_dispatch`
  """
  def dispatch(%{message_type: :command, message: command} = context) do
    user = Context.user(context)
    handler = HandlerResolver.get_handler!(context, CustomCommandHandler)

    with {:ok, context} <- execute({handler, :before_dispatch, [command, context]}, context),
         {:ok, context} <- execute({handler, :handle_authorize, [user, command, context]}, context),
         {:ok, context} <- execute({handler, :handle_dispatch, [command, context]}, context) do
      return_last_pipeline(context)
    end
  end

  def dispatch(%{message_type: :query, message: filter_map} = context) do
    %{__struct__: query_module} = filter_map

    user = Context.user(context)
    bindings = query_module.__bindings__()
    filter_list = Query.create_filter_list(context)
    handler = HandlerResolver.get_handler!(context, CustomQueryHandler)

    context =
      context
      |> Context.put_private(:bindings, bindings)
      |> Context.put_private(:filters, Enum.into(filter_list, %{}))

    with {:ok, context} <- execute({handler, :before_dispatch, [filter_map, context]}, context),
         {:ok, context} <- execute({handler, :create_query, [filter_list, context]}, context),
         # - Apply Query Scoping
         query = Context.get_last_pipeline(context),
         {:ok, context} <- execute({handler, :handle_scope, [user, query, context]}, context) do
      execute_query(handler, context)
    end
  end

  defp execute_query(handler, context) do
    # put the query into the context
    query = Context.get_last_pipeline(context)
    context = Context.put_private(context, :query, query)
    opts = Context.options(context)

    # -  If `execution` is set to false, just return the query;
    #     otherwise, execute `handle_dispatch`
    case Context.get_option(context, :execute) do
      false ->
        return_final(query, context)

      true ->
        with {:ok, context} <- execute({handler, :handle_dispatch, [query, context, opts]}, context) do
          return_last_pipeline(context)
        end
    end
  end

  defp return_last_pipeline(context) do
    context
    |> Context.get_last_pipeline()
    |> return_final(context)
  end

  defp return_final(value, context) do
    case Context.get_option(context, :return) do
      :context -> {:ok, context}
      _ -> {:ok, value}
    end
  end

  defp execute({handler, callback, args}, context) do
    case apply(handler, callback, args) do
      {:error, error} ->
        {:error,
         context
         |> Context.put_error(error)
         |> Context.put_pipeline(callback, {:error, error})}

      :error ->
        {:error,
         context
         |> Context.put_error(:error)
         |> Context.put_pipeline(callback, :error)}

      {:ok, %Context{} = context} ->
        {:ok, Context.put_pipeline(context, callback, :ok)}

      {:ok, {:ok, response}} ->
        {:ok, Context.put_pipeline(context, callback, response)}

      {:ok, response} ->
        {:ok, Context.put_pipeline(context, callback, response)}

      response ->
        {:ok, Context.put_pipeline(context, callback, response)}
    end
  end
end
