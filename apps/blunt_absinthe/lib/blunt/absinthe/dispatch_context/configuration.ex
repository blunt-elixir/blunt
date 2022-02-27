defmodule Blunt.Absinthe.DispatchContext.Configuration do
  @type resolution :: Absinthe.Resolution.t()
  @callback configure(resolution()) :: keyword()

  alias Blunt.Absinthe.Config

  def configure(resolution) do
    configuration = Config.dispatch_context_configuration()
    configuration.configure(resolution)
  end
end
