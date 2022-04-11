defmodule Blunt.DispatchContext.Configuration do
  @type message_module :: atom()
  @type context :: Blunt.DispatchContext
  @callback configure(message_module(), context()) :: context()

  def configure(message_module, context) do
    configuration = Blunt.Config.dispatch_context_configuration()
    configuration.configure(message_module, context)
  end
end
