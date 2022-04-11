defmodule Blunt.Absinthe.DispatchContext.Configuration do
  @type message_module :: atom()
  @type resolution :: Absinthe.Resolution.t()
  @callback configure(message_module(), resolution()) :: keyword()

  alias Blunt.Absinthe.Config

  def configure(message_module, resolution) do
    configuration = Config.dispatch_context_configuration()
    configuration.configure(message_module, resolution)
  end
end
