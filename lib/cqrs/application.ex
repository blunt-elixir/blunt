defmodule Cqrs.Application do
  use Application

  def start(_type, _args) do
    [Cqrs.DispatchContext.Shipper]
    |> Supervisor.start_link(strategy: :one_for_one, name: Cqrs.Supervisor)
  end
end
