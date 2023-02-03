defmodule Blunt.Commanded.DispatchStrategy do
  alias Blunt.Dialect
  alias Blunt.Commanded.CommandEnrichment

  import Blunt.DispatchStrategy

  @behaviour Blunt.DispatchStrategy

  @impl true
  def dispatch(%{message_type: :command} = context) do
    %{message_module: message_module, message: command, opts: opts} = context

    enrichment = PipelineResolver.get_pipeline!(context, CommandEnrichment)
    dialect = Dialect.Registry.get_dialect!()
    commanded_app = Blunt.Commanded.Dialect.commanded_app!(dialect)

    case DispatchContext.get_return(context) do
      :command_context ->
        {:ok, context}

      :command ->
        return_final(command, context)

      _ ->
        with {:ok, context} <- execute({enrichment, :enrich, [command, context]}, context) do
          {:ok, result} <-
            commanded_app.dispatch command, opts do
            end
        end
    end
  end
end
