defmodule Cqrs.DispatchContext.Shipper do
  @type context :: Cqrs.DispatchContext.t()
  @callback ship(context()) :: :ok

  alias Cqrs.{Config, Behaviour}

  def ship(context) do
    case Config.context_shipper() do
      nil ->
        :ok

      shipper ->
        shipper = Behaviour.validate!(shipper, __MODULE__)
        shipper.ship(context)
    end
  end
end
