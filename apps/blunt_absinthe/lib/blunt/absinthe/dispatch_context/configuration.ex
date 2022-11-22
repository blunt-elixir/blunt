defmodule Blunt.Absinthe.DispatchContext.Configuration do
  @type message_module :: atom()
  @type resolution :: Absinthe.Resolution.t()
  @callback configure(message_module(), resolution()) :: keyword()

  alias Blunt.Absinthe.Config

  def configure(message_module, %{context: context} = resolution) do
    configuration = Config.dispatch_context_configuration()

    metadata = configuration.configure(message_module, resolution)

    Keyword.put(metadata, :blunt, Map.get(context, :blunt))
  end
end
