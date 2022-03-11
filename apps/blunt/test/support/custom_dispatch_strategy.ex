defmodule Blunt.CustomDispatchStrategy do
  @behaviour Blunt.DispatchStrategy

  import Blunt.DispatchStrategy

  alias Blunt.Query
  alias Blunt.DispatchContext, as: Context
  alias Blunt.DispatchStrategy.PipelineResolver
  alias Blunt.CustomDispatchStrategy.{CustomCommandHandler, CustomQueryHandler}

  @type context :: Context.t()
  @type query_context :: Context.query_context()
  @type command_context :: Context.command_context()

  @spec dispatch(command_context() | query_context()) ::
          {:error, context()} | {:ok, context() | any}

  @moduledoc """
  Receives a `DispatchContext`, locates the message pipeline, and runs the pipeline pipeline.

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
    pipeline = PipelineResolver.get_pipeline!(context, CustomCommandHandler)

    with {:ok, context} <- execute({pipeline, :before_dispatch, [command, context]}, context),
         {:ok, context} <- execute({pipeline, :handle_authorize, [user, command, context]}, context),
         {:ok, context} <- execute({pipeline, :handle_dispatch, [command, context]}, context) do
      return_last_pipeline(context)
    end
  end

  def dispatch(%{message_type: :query, message: filter_map} = context) do
    user = Context.user(context)
    bindings = Query.bindings(context)
    filter_list = Query.create_filter_list(context)
    pipeline = PipelineResolver.get_pipeline!(context, CustomQueryHandler)

    context =
      context
      |> Context.put_private(:bindings, bindings)
      |> Context.put_private(:filters, Enum.into(filter_list, %{}))

    with {:ok, context} <- execute({pipeline, :before_dispatch, [filter_map, context]}, context),
         {:ok, context} <- execute({pipeline, :create_query, [filter_list, context]}, context),
         # - Apply Query Scoping
         query = Context.get_last_pipeline(context),
         {:ok, context} <- execute({pipeline, :handle_scope, [user, query, context]}, context) do
      execute_query(pipeline, context)
    end
  end

  defp execute_query(pipeline, context) do
    # put the query into the context
    query = Context.get_last_pipeline(context)
    context = Context.put_private(context, :query, query)

    case Context.get_return(context) do
      :query_context ->
        {:ok, context}

      :query ->
        return_final(query, context)

      _ ->
        opts = Context.options(context)

        with {:ok, context} <- execute({pipeline, :handle_dispatch, [query, context, opts]}, context) do
          return_last_pipeline(context)
        end
    end
  end
end
