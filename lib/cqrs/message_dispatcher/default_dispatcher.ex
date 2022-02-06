defmodule Cqrs.MessageDispatcher.DefaultDispatcher do
  @behaviour Cqrs.MessageDispatcher

  alias Cqrs.Query
  alias Cqrs.ExecutionContext, as: Context
  alias Cqrs.MessageDispatcher.HandlerProvider

  @spec dispatch(Context.t()) :: {:error, Context.t()} | {:ok, Context.t() | any}
  @doc """
  Receives an `ExecutionContext`, locates the message handler, and runs the handler pipeline.

  ## CommandHandler Pipeline

  1. `before_dispatch`
  2. `handle_authorize`
  3. `handle_dispatch`

  ## QueryHandler Pipeline

  1. `before_dispatch`
  2. `create_query`
  3. `handle_scope`
  4. `handle_dispatch`
  """
  def dispatch(%{message_type: :command, message: command} = context) do
    handler = HandlerProvider.get_handler!(context)

    with {:ok, context} <- execute({handler, :before_dispatch, [command, context]}, context),
         {:ok, context} <- execute({handler, :handle_authorize, [command, context]}, context),
         {:ok, context} <- execute({handler, :handle_dispatch, [command, context]}, context) do
      return_last_pipeline(context)
    end
  end

  def dispatch(%{message_type: :query, message: filter_map} = context) do
    user = Context.user(context)
    handler = HandlerProvider.get_handler!(context)
    filter_list = Query.create_filter_list(filter_map, context)
    context = Context.put_private(context, :filters, filter_list)

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

    # -  If `execution` is set to false, just return the query;
    #     otherwise, execute `handle_dispatch`
    case Context.get_option(context, :execute) do
      false ->
        return_final(query, context)

      true ->
        with {:ok, context} <- execute({handler, :handle_dispatch, [query, context]}, context) do
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

  defp execute({module, step, args}, context) do
    case apply(module, step, args) do
      {:error, error} ->
        {:error,
         context
         |> Context.put_error(error)
         |> Context.put_pipeline(step, {:error, error})}

      :error ->
        {:error,
         context
         |> Context.put_error(:error)
         |> Context.put_pipeline(step, :error)}

      {:ok, %Context{} = context} ->
        {:ok, Context.put_pipeline(context, step, :ok)}

      {:ok, {:ok, response}} ->
        {:ok, Context.put_pipeline(context, step, response)}

      {:ok, response} ->
        {:ok, Context.put_pipeline(context, step, response)}

      response ->
        {:ok, Context.put_pipeline(context, step, response)}
    end
  end
end
