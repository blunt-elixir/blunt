defmodule Cqrs.CustomDispatchStrategy.CustomCommandHandler do
  @type user :: map()
  @type command :: struct()
  @type context :: Cqrs.DispatchContext.command_context()

  @callback before_dispatch(command, context) :: {:ok, context()} | {:error, any()}
  @callback handle_authorize(user, command, context) :: {:ok, context()} | {:error, any()} | :error
  @callback handle_dispatch(command, context) :: any()

  defmacro __using__(_opts) do
    quote do
      @behaviour Cqrs.CustomDispatchStrategy.CustomCommandHandler

      @impl true
      def handle_authorize(_user, _command, context),
        do: {:ok, context}

      @impl true
      def before_dispatch(_command, context),
        do: {:ok, context}

      defoverridable handle_authorize: 3, before_dispatch: 2
    end
  end
end
