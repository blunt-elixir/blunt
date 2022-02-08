defmodule Cqrs.Config do
  @moduledoc false

  def create_jason_encoders?(opts) do
    explicit = Keyword.get(opts, :create_jason_encoders?, true)
    configured = get(:create_jason_encoders, true)

    explicit && configured
  end

  def context_shipper, do: get(:context_shipper)

  defp get(key, default \\ nil), do: Application.get_env(:cqrs_tools, key, default)
end
