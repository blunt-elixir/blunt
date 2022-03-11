defmodule Blunt.CommandHandler do
  @type user :: map()
  @type command :: struct()
  @type context :: Blunt.DispatchContext.command_context()

  @callback handle_dispatch(command, context) :: any()

  defmacro __using__(_opts) do
    quote do
      use Blunt.Message.Compilation
      @behaviour Blunt.CommandHandler
    end
  end
end
