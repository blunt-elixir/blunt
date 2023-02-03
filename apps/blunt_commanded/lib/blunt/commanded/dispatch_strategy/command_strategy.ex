defmodule Blunt.Commanded.DispatchStrategy.CommandStrategy do
  alias Blunt.Commanded.Dialect, as: CommandedDialect
  alias Blunt.{Dialect, DispatchContext, PipelineResolver}

  @behaviour Blunt.DispatchStrategy

  @impl true
  def dispatch(%{message_type: :command} = context) do
    %{message_module: message_module, message: command, opts: opts} = context

    case DispatchContext.get_return(context) do
      :command_context ->
        {:ok, context}

      :command ->
        return_final(command, context)

      _ ->
        # fetch the currently configured Blunt dialect
        dialect = Dialect.Registry.get_dialect!()
        commanded_app = CommandedDialect.commanded_app!(dialect)

        opts = Keyword.put(opts, :metadata, metadata_from_context(context))
        enrichment = PipelineResolver.get_pipeline!(context, CommandEnrichment)

        with {:ok, context} <- execute({enrichment, :enrich, [command, context]}, context) do
          case commanded_app.dispatch(command, opts) do
            {:ok, execution_result} ->
              %{events: events} = execution_result

              context =
                context
                |> DispatchContext.put_pipeline(:commanded, events)
                |> DispatchContext.put_private(execution_result)

              {:ok, context}

            {:error, error} ->
              {:error,
               context
               |> DispatchContext.put_error(error)
               |> DispatchContext.put_pipeline(:commanded, {:error, error})}
          end
        end
    end
  end

  def metadata_from_context(%{id: dispatch_id} = context) do
    user = Map.get(context, :user, %{}) || %{}

    options = DispatchContext.options_map(context)

    context
    |> Map.take([
      :created_at,
      :message,
      :message_module,
      :message_type,
      :user_supplied_fields
    ])
    |> Map.merge(options)
    |> Map.put(:dispatch_id, dispatch_id)
    |> Map.put(:dispatched_at, DateTime.utc_now())
  end
end
