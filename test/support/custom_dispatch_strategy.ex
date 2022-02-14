defmodule Cqrs.CustomDispatchStrategy do
  @behaviour Cqrs.DispatchStrategy

  import Cqrs.DispatchStrategy

  alias Cqrs.Query
  alias Cqrs.DispatchContext, as: Context
  alias Cqrs.DispatchStrategy.PipelineResolver
  alias Cqrs.CustomDispatchStrategy.{CustomCommandPipeline, CustomQueryPipeline}

  @type context :: Context.t()
  @type query_context :: Context.query_context()
  @type command_context :: Context.command_context()

  @spec dispatch(command_context() | query_context()) ::
          {:error, context()} | {:ok, context() | any}

  @moduledoc """
  Receives a `DispatchContext`, locates the message pipeline, and runs the pipeline pipeline.

  ## CustomCommandPipeline Pipeline

  1. `before_dispatch`
  2. `handle_authorize`
  3. `handle_dispatch`

  ## CustomQueryPipeline Pipeline

  1. `before_dispatch`
  2. `create_query`
  3. `handle_scope`
  4. `handle_dispatch`
  """
  def dispatch(%{message_type: :command, message: command} = context) do
    user = Context.user(context)
    pipeline = PipelineResolver.get_pipeline!(context, CustomCommandPipeline)

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
    pipeline = PipelineResolver.get_pipeline!(context, CustomQueryPipeline)

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
    opts = Context.options(context)

    # -  If `execution` is set to false, just return the query;
    #     otherwise, execute `handle_dispatch`
    case Context.get_option(context, :execute) do
      false ->
        return_final(query, context)

      true ->
        with {:ok, context} <- execute({pipeline, :handle_dispatch, [query, context, opts]}, context) do
          return_last_pipeline(context)
        end
    end
  end
end
