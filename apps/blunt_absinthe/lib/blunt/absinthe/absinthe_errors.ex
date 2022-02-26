defmodule Blunt.Absinthe.AbsintheErrors do
  @moduledoc false

  alias Blunt.DispatchContext

  @type context :: Blunt.DispatchContext.t()

  @spec from_dispatch_context(context()) :: list

  def from_dispatch_context(context) do
    # TODO: Use more info in context to supply useful errors
    context
    |> DispatchContext.errors()
    |> Enum.map(fn
      {key, messages} when is_list(messages) or is_map(messages) ->
        Enum.map(messages, fn message -> %{message: "#{key} #{message}"} end)

      {key, message} when is_binary(message) ->
        %{message: "#{key} #{message}"}
    end)
  end
end
