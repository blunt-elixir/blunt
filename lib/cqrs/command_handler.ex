defmodule Cqrs.CommandHandler do
  @type command :: struct()
  @type context :: Cqrs.DispatchContext.t()

  @callback before_dispatch(command, context) :: {:ok, context()} | {:error, any()}
  @callback handle_authorize(command, context) :: {:ok, context()} | {:error, any()} | :error
  @callback handle_dispatch(command, context) :: any()

  defmacro __using__(_opts) do
    quote do
      import Ecto.Query

      @behaviour Cqrs.CommandHandler

      @impl true
      def handle_authorize(_command, context),
        do: {:ok, context}

      @impl true
      def before_dispatch(_command, context),
        do: {:ok, context}

      defoverridable handle_authorize: 2, before_dispatch: 2
    end
  end
end
