defmodule Blunt.DispatchContext.DefaultConfiguration do
  @behaviour Blunt.DispatchContext.Configuration

  def configure(_message_module, context), do: context
end
