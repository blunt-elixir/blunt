defmodule Blunt.Absinthe.Middleware do
  @moduledoc false
  alias Blunt.Absinthe.Middleware

  def middleware(opts) do
    before_resolve = Keyword.get(opts, :before_resolve, &Middleware.identity/2)
    after_resolve = Keyword.get(opts, :after_resolve, &Middleware.identity/2)
    {before_resolve, after_resolve}
  end

  def configured do
    before_resolve = Blunt.Absinthe.Config.before_resolve_middleware()
    after_resolve = Blunt.Absinthe.Config.after_resolve_middleware()
    {before_resolve, after_resolve}
  end

  def identity(res, _), do: res
end
