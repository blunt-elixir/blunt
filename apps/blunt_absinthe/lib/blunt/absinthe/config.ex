defmodule Blunt.Absinthe.Config do
  alias Blunt.Absinthe.DispatchContext
  alias Blunt.Behaviour

  @doc false
  def dispatch_context_configuration do
    :dispatch_context_configuration
    |> get(DispatchContext.DefaultConfiguration)
    |> Behaviour.validate!(DispatchContext.Configuration)
  end

  @doc false
  def before_resolve_middleware do
    get(:before_resolve_middleware, quote(do: fn res, _ -> res end))
  end

  @doc false
  def after_resolve_middleware do
    get(:after_resolve_middleware, quote(do: fn res, _ -> res end))
  end

  defp get(key, default), do: Application.get_env(:blunt_absinthe, key, default)
end
