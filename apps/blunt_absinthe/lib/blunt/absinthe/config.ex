defmodule Blunt.Absinthe.Config do
  alias Blunt.Absinthe.DispatchContext
  alias Blunt.Behaviour

  @doc false
  def dispatch_context_configuration do
    :dispatch_context_configuration
    |> get(DispatchContext.DefaultConfiguration)
    |> Behaviour.validate!(DispatchContext.Configuration)
  end

  defp get(key, default), do: Application.get_env(:blunt_absinthe, key, default)
end
