defmodule Blunt.Absinthe.AbsintheErrors do
  @moduledoc false

  alias Blunt.DispatchContext

  @type context :: Blunt.DispatchContext.t()

  @spec from_dispatch_context(context()) :: list

  def from_dispatch_context(%{id: dispatch_id} = context) do
    # TODO: Use more info in context to supply useful errors
    case DispatchContext.errors(context) do
      error when is_binary(error) ->
        [message: error, dispatch_id: dispatch_id]

      errors when is_map(errors) ->
        Enum.map(errors, fn
          {key, messages} when is_list(messages) or is_map(messages) ->
            Enum.map(messages, fn message -> [message: "#{key} #{message}", dispatch_id: dispatch_id] end)

          {key, message} when is_binary(message) ->
            [message: "#{key} #{message}", dispatch_id: dispatch_id]
        end)
    end
  end
end
