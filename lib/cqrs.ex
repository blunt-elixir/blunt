defmodule Cqrs do
  use Application

  def start(_type, _args) do
    [Cqrs.DispatchContext.Shipper]
    |> Supervisor.start_link(strategy: :one_for_one, name: Cqrs.Supervisor)
  end

  defmacro __using__(_opts) do
    quote do
      import Cqrs, only: :macros
    end
  end

  defmacro defcommand(opts \\ [], do: body) do
    quote do
      use Cqrs.Command, unquote(opts)
      unquote(body)
    end
  end

  defmacro defquery(opts \\ [], do: body) do
    quote do
      use Cqrs.Query, unquote(opts)
      unquote(body)
    end
  end
end
