defmodule Cqrs.DispatchContext.Shipper do
  @type context :: Cqrs.DispatchContext.t()
  @callback ship(context()) :: :ok

  def ship(context) do
    case Application.get_env(:cqrs_tools, :context_shipper) do
      nil -> :ok
      shipper -> shipper.ship(context)
    end
  end
end
