defmodule Cqrs.CommandTest.Protocol.DispatchWithHandlerHandler do
  use Cqrs.CommandHandler
  alias Cqrs.DispatchContext, as: Context

  defp reply(context, pipeline) do
    context
    |> Context.get_option(:reply_to)
    |> send({pipeline, context})
  end

  @impl true
  def before_dispatch(command, context) do
    reply(context, :before_dispatch)

    if Context.get_option(context, :error_at) == :before_dispatch do
      {:error, :before_dispatch_error}
    else
      with {:ok, child} <- get_some_dependency(command) do
        {:ok, Context.put_private(context, :child, child)}
      end
    end
  end

  @impl true
  def handle_authorize(_command, context) do
    reply(context, :handle_authorize)

    if Context.get_option(context, :error_at) == :handle_authorize do
      {:error, :handle_authorize_error}
    else
      {:ok, context}
    end
  end

  @impl true
  def handle_dispatch(_command, context) do
    reply(context, :handle_dispatch)

    if Context.get_option(context, :error_at) == :handle_dispatch do
      {:error, :handle_dispatch_error}
    else
      "YO-HOHO"
    end
  end

  defp get_some_dependency(_command) do
    {:ok, %{related: "value"}}
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
