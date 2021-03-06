defmodule Blunt.CommandTest.Protocol.DispatchWithPipelineHandler do
  use Blunt.CommandHandler
  alias Blunt.DispatchContext, as: Context

  defp reply(context, pipeline) do
    context
    |> Context.get_option(:reply_to)
    |> send({pipeline, context})
  end

  @impl true
  def handle_dispatch(_command, context) do
    reply(context, :handle_dispatch)

    if Context.get_option(context, :return_error) do
      {:error, :handle_dispatch_error}
    else
      "YO-HOHO"
    end
  end
end

defmodule Blunt.CommandTest.Protocol.CommandWithMetaHandler do
  use Blunt.CommandHandler

  def handle_dispatch(_command, _context) do
    :ok
  end
end
