defmodule Blunt.AggregateRoot do
  @type state :: struct()
  @type domain_event :: struct()

  @callback apply(state, domain_event) :: state
end
