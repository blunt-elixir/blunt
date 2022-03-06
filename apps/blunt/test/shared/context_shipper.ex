defmodule Blunt.Test.ContextShipper do
  @behaviour Blunt.DispatchContext.Shipper

  alias Blunt.DispatchContext

  def ship(context) do
    case DispatchContext.get_option(context, :reply_to) do
      nil -> :ok
      reply_to -> send(reply_to, {:context, context})
    end
  end
end
