defmodule Blunt.Commanded.DispatchStrategy do
  alias Blunt.Commanded.DispatchStrategy.CommandStrategy

  @behaviour Blunt.DispatchStrategy

  @impl true
  def dispatch(%{message_type: :command} = context) do
    CommandStrategy.dispatch(context)
  end
end
