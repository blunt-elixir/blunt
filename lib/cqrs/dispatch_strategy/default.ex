defmodule Cqrs.DispatchStrategy.Default do
  @behaviour Cqrs.DispatchStrategy

  import Cqrs.DispatchStrategy

  alias Cqrs.DispatchContext, as: Context
  alias Cqrs.DispatchStrategy.PipelineResolver
  alias Cqrs.{CommandPipeline, Query, QueryPipeline}

  @type context :: Context.t()
  @type query_context :: Context.query_context()
  @type command_context :: Context.command_context()

  @spec dispatch(command_context() | query_context()) ::
          {:error, context()} | {:ok, context() | any}

  @moduledoc """
  Receives a `DispatchContext`, locates a message pipeline, and runs the pipeline's ...uh pipeline.

  ## CommandPipeline Pipeline

  1. `handle_dispatch`

  ## QueryPipeline Pipeline

  1. `create_query`
  2. `handle_dispatch`
  """
  def dispatch(%{message_type: :command, message: command} = context) do
    pipeline = PipelineResolver.get_pipeline!(context, CommandPipeline)

    with {:ok, context} <- execute({pipeline, :handle_dispatch, [command, context]}, context) do
      return_last_pipeline(context)
    end
  end

  def dispatch(%{message_type: :query} = context) do
    bindings = Query.bindings(context)
    filter_list = Query.create_filter_list(context)
    pipeline = PipelineResolver.get_pipeline!(context, QueryPipeline)

    context =
      context
      |> Context.put_private(:bindings, bindings)
      |> Context.put_private(:filters, Enum.into(filter_list, %{}))

    with {:ok, context} <- execute({pipeline, :create_query, [filter_list, context]}, context) do
      # put the query into the context
      query = Context.get_last_pipeline(context)
      context = Context.put_private(context, :query, query)

      case Context.get_return(context) do
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
end
