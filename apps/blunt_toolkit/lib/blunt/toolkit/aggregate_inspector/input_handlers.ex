defmodule Blunt.Toolkit.AggregateInspector.InputHandlers do
  alias Blunt.Toolkit.AggregateInspector.InputHandlers

  defmacro __using__(_opts) do
    quote do
      import InputHandlers, only: :macros
    end
  end

  defmacro handle_common_input(model, model_field, msg, on_enter: body) do
    quote do
      current_value = Map.get(unquote(model), unquote(model_field))

      case unquote(msg) do
        {:event, %{key: key}} when key in @delete_keys ->
          Map.put(unquote(model), unquote(model_field), String.slice(current_value, 0..-2))

        {:event, %{ch: ch}} when ch > 0 ->
          Map.put(unquote(model), unquote(model_field), current_value <> <<ch::utf8>>)

        {:event, %{key: @enter_key}} ->
          unquote(body).(current_value)

        _ ->
          unquote(model)
      end
    end
  end
end
