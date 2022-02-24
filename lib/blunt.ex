defmodule Blunt do
  use Application

  def start(_type, _args) do
    [Blunt.DispatchContext.Shipper]
    |> Supervisor.start_link(strategy: :one_for_one, name: Blunt.Supervisor)
  end

  defmacro __using__(_opts) do
    quote do
      import Blunt, only: :macros
    end
  end

  defmacro defcommand(opts \\ [], do: body) do
    quote do
      use Blunt.Command, unquote(opts)
      unquote(body)
    end
  end

  defmacro defquery(opts \\ [], do: body) do
    quote do
      use Blunt.Query, unquote(opts)
      unquote(body)
    end
  end
end
