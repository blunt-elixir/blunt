defmodule Blunt.DispatchStrategy.Default do
  @behaviour Blunt.DispatchStrategy

  import Blunt.DispatchStrategy

  alias Blunt.DispatchContext
  alias Blunt.DispatchStrategy.PipelineResolver
  alias Blunt.{CommandPipeline, Query, QueryPipeline}

  @type context :: DispatchContext.t()

  @spec dispatch(context()) :: {:ok, context() | any()} | {:error, context()}

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
      |> DispatchContext.put_private(:bindings, bindings)
      |> DispatchContext.put_private(:filters, Enum.into(filter_list, %{}))

    with {:ok, context} <- execute({pipeline, :create_query, [filter_list, context]}, context) do
      # put the query into the context
      query = DispatchContext.get_last_pipeline(context)
      context = DispatchContext.put_private(context, :query, query)

      case DispatchContext.get_return(context) do
        :query_context ->
          {:ok, context}

        :query ->
          return_final(query, context)

        _ ->
          opts = DispatchContext.options(context)

          with {:ok, context} <- execute({pipeline, :handle_dispatch, [query, context, opts]}, context) do
            return_last_pipeline(context)
          end
      end
    end
  end
end
