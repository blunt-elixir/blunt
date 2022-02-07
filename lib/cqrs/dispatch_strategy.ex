defmodule Cqrs.DispatchStrategy do
  alias Cqrs.{Behaviour, DispatchContext}

  @type context :: DispatchContext.t()

  @callback dispatch(context()) :: {:ok, any()} | {:error, context()}
  def dispatch(context) do
    get_strategy().dispatch(context)
  end

  defp get_strategy do
    :cqrs_tools
    |> Application.get_env(:dispatch_strategy, __MODULE__.Default)
    |> Behaviour.validate!(__MODULE__)
  end
end
