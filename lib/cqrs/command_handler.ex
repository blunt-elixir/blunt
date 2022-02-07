defmodule Cqrs.CommandHandler do
  @type user :: map()
  @type command :: struct()
  @type context :: Cqrs.DispatchContext.command_context()

  @callback handle_dispatch(command, context) :: any()

  defmacro __using__(_opts) do
    quote do
      @behaviour Cqrs.CommandHandler
    end
  end
end
