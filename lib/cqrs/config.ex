defmodule Cqrs.Config do
  # TODO: Document configuration

  alias Cqrs.{Behaviour, DispatchStrategy, DispatchContext.Shipper}

  @doc false
  def create_jason_encoders?(opts) do
    explicit = Keyword.get(opts, :create_jason_encoders?, true)
    configured = get(:create_jason_encoders, true)

    explicit && configured
  end

  @doc false
  def dispatch_strategy! do
    :dispatch_strategy
    |> get(DispatchStrategy.Default)
    |> Behaviour.validate!(DispatchStrategy)
  end

  @doc false
  def context_shipper! do
    case get(:context_shipper) do
      nil -> nil
      shipper -> Behaviour.validate!(shipper, Shipper)
    end
  end

  defp get(key, default \\ nil), do: Application.get_env(:cqrs_tools, key, default)
end
