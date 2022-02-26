defmodule Blunt.Toolkit.AggregateInspector.Commands do
  def load_stream(%{stream: stream, aggregate: aggregate, eventstore: eventstore}) do
    with {:ok, events} <- eventstore.read_stream_forward(stream) do
      step_through(events, aggregate)
    end
  end

  defp step_through(events, aggregate_module) do
    initial_state = struct(aggregate_module)
    acc = {initial_state, [%{state: initial_state, event: nil, event_type: "initial state"}]}

    {_current_state, states} =
      events
      |> Enum.reduce(acc, fn event, {current_state, states} ->
        next_state = aggregate_module.apply(current_state, event.data)

        entry = %{
          state: next_state,
          event: event.data,
          event_type: String.trim_leading(event.event_type, "Elixir.")
        }

        {next_state, [entry | states]}
      end)

    Enum.reverse(states)
  end

  def get_event_store!(eventstore) do
    eventstore = String.to_atom("Elixir." <> eventstore)
    Blunt.Behaviour.validate!(eventstore, EventStore)

    {:ok, _} = Application.ensure_all_started(:eventstore)

    case eventstore.start_link() do
      {:ok, _} -> eventstore
      {:error, {:already_started, _}} -> eventstore
      other -> raise inspect(other)
    end
  end

  def get_aggregate!(aggregate) do
    ("Elixir." <> aggregate)
    |> String.to_atom()
    |> Blunt.Behaviour.validate!(Blunt.AggregateRoot)
  end
end
