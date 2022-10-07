defmodule Blunt.Absinthe.AbsintheErrors do
  @moduledoc false

  alias Blunt.DispatchContext

  @type context :: Blunt.DispatchContext.t()

  @spec from_dispatch_context(context()) :: list

  def from_dispatch_context(%{id: dispatch_id} = context) do
    # TODO: Use more info in context to supply useful errors
    case DispatchContext.errors(context) do
      error when is_atom(error) ->
        [message: to_string(error), dispatch_id: dispatch_id]

      error when is_binary(error) ->
        [message: error, dispatch_id: dispatch_id]

      errors when is_map(errors) ->
        format(errors, dispatch_id: dispatch_id)
    end
  end

  def format(errors, extra_properties \\ []) when is_map(errors) do
    Enum.reduce(errors, [], fn
      {:generic, messages}, acc when is_list(messages) or is_map(messages) ->
        Enum.map(messages, fn message -> [message: message] end) ++ acc

      {key, messages}, acc when is_list(messages) or is_map(messages) ->
        Enum.flat_map(leaves_with_path(messages, [key]), fn
          {path, messages} ->
            path = Enum.map(path, &to_string/1)
            label = Enum.join(path, ".")
            message = messages |> List.wrap() |> Enum.join(", ")

            [[message: "#{label} #{message}", path: path]]
        end) ++ acc

      {key, message}, acc when is_binary(message) ->
        [[message: "#{key} #{message}", path: [key]] | acc]
    end)
    |> Enum.map(&Keyword.merge(&1, extra_properties))
  end

  def leaves_with_path(input, path \\ []) do
    Enum.flat_map(input, fn {key, value} ->
      full = [key | path]
      if is_map(value), do: leaves_with_path(value, full), else: [{Enum.reverse(full), value}]
    end)
  end
end
