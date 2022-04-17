defmodule Blunt.Absinthe.DispatchContext.DefaultConfiguration do
  @behaviour Blunt.Absinthe.DispatchContext.Configuration

  def configure(_message_module, _res), do: []
end
