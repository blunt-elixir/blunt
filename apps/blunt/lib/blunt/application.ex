defmodule Blunt.Application do
  @moduledoc false
  use Application

  def start(_type, _args) do
    children = [
      Blunt.Dialect.Registry
    ]

    opts = [strategy: :one_for_one, name: Blunt.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
