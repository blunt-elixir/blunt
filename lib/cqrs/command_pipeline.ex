defmodule Cqrs.CommandPipeline do
  @type user :: map()
  @type command :: struct()
  @type context :: Cqrs.DispatchContext.command_context()

  @callback handle_dispatch(command, context) :: any()

  defmacro __using__(_opts) do
    quote do
      use Cqrs.Message.Compilation
      @behaviour Cqrs.CommandPipeline
    end
  end
end
