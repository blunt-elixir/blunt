defmodule Cqrs.CommandTest.Protocol.DispatchWithHandlerHandler do
  use Cqrs.CommandHandler
  alias Cqrs.DispatchContext, as: Context

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

defmodule Cqrs.CommandTest.Protocol.CommandWithEventDerivationsHandler do
  use Cqrs.CommandHandler

  alias Cqrs.CommandTest.Protocol.{DefaultEvent, EventWithExtras, EventWithDrops, EventWithExtrasAndDrops}
  alias alias Cqrs.CommandTest.Events.NamespacedEventWithExtrasAndDrops

  @impl true
  def handle_dispatch(command, _context) do
    %{
      default_event: DefaultEvent.create(command),
      event_with_drops: EventWithDrops.create(command),
      event_with_extras: EventWithExtras.create(command, date: Date.utc_today()),
      event_with_extras_and_drops: EventWithExtrasAndDrops.create(command, date: Date.utc_today()),
      namespaced_event_with_extras_and_drops: NamespacedEventWithExtrasAndDrops.create(command, date: Date.utc_today())
    }
  end
end
