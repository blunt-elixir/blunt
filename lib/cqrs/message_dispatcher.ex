defmodule Cqrs.MessageDispatcher do
  alias Cqrs.{Behaviour, ExecutionContext, MessageDispatcher.DefaultDispatcher}

  defmodule Error do
    defexception [:message]
  end

  @type context :: ExecutionContext.t()

  @callback dispatch(context()) :: {:ok, any()} | {:error, context()}
  def dispatch(context) do
    get_dispatcher().dispatch(context)
  end

  defp get_dispatcher do
    :cqrs_tools
    |> Application.get_env(:message_dispatcher, DefaultDispatcher)
    |> Behaviour.validate!(__MODULE__)
  end
end
