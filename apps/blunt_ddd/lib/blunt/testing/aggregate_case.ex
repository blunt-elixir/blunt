defmodule Blunt.Testing.AggregateCase do
  use ExUnit.CaseTemplate

  alias Blunt.Testing.AggregateCase
  alias Blunt.{AggregateRoot, Behaviour}

  using aggregate: aggregate do
    quote do
      import Blunt.Testing.AggregateCase, only: :macros
      @aggregate Behaviour.validate!(unquote(aggregate), AggregateRoot)
    end
  end

  defstruct [:events, :error, :state]

  defmacro execute_command(initial_events \\ [], command) do
    quote do
      AggregateCase.execute(@aggregate, unquote(initial_events), unquote(command))
    end
  end

  @doc false
  def execute(aggregate_module, initial_events, command) do
    initial_state = struct(aggregate_module)
    state = evolve(aggregate_module, initial_state, initial_events)

    case aggregate_module.execute(state, command) do
      {:error, _reason} = error ->
        %__MODULE__{events: [], error: error, state: state}

      events ->
        final_state = evolve(aggregate_module, state, events)
        %__MODULE__{events: List.wrap(events), error: nil, state: final_state}
    end
  end

  @doc false
  def evolve(aggregate_module, state, events) do
    events
    |> List.wrap()
    |> Enum.reduce(state, &aggregate_module.apply(&2, &1))
  end
end
