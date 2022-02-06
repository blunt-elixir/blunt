defmodule Cqrs.DispatchStrategy do
  alias Cqrs.{Behaviour, ExecutionContext, DispatchStrategy.DefaultDispatchStrategy}

  defmodule Error do
    defexception [:message]
  end

  @type context :: ExecutionContext.t()

  @callback dispatch(context()) :: {:ok, any()} | {:error, context()}
  def dispatch(context) do
    get_strategy().dispatch(context)
  end

  defp get_strategy do
    :cqrs_tools
    |> Application.get_env(:dispatch_strategy, DefaultDispatchStrategy)
    |> Behaviour.validate!(__MODULE__)
  end
end
