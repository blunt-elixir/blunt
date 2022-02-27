defmodule Blunt.DispatchContext.Configuration do
  @type context :: Blunt.DispatchContext
  @callback configure(context()) :: context()

  def configure(context) do
    configuration = Blunt.Config.dispatch_context_configuration()
    configuration.configure(context)
  end
end
