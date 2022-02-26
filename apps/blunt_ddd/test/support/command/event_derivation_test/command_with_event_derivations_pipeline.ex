defmodule Support.Command.EventDerivationTest.CommandWithEventDerivationsPipeline do
  use Blunt.CommandPipeline

  alias Blunt.CommandTest.Events.NamespacedEventWithExtrasAndDrops

  alias Support.Command.EventDerivationTest.{
    DefaultEvent,
    EventWithExtras,
    EventWithDrops,
    EventWithExtrasAndDrops
  }

  @impl true
  def handle_dispatch(command, _context) do
    %{
      default_event: DefaultEvent.new(command),
      event_with_drops: EventWithDrops.new(command),
      event_with_extras: EventWithExtras.new(command, date: Date.utc_today()),
      event_with_extras_and_drops: EventWithExtrasAndDrops.new(command, date: Date.utc_today()),
      namespaced_event_with_extras_and_drops: NamespacedEventWithExtrasAndDrops.new(command, date: Date.utc_today())
    }
  end
end
