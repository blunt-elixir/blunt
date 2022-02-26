defmodule Blunt.Absinthe.Middleware do
  @moduledoc false
  alias Blunt.Absinthe.Middleware

  def middleware(opts) do
    before_resolve = Keyword.get(opts, :before_resolve, &Middleware.identity/2)
    after_resolve = Keyword.get(opts, :after_resolve, &Middleware.identity/2)
    {before_resolve, after_resolve}
  end

  def identity(res, _), do: res
end
