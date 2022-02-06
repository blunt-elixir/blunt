defmodule Cqrs.ValueObject do
  defmacro __using__(opts) do
    quote do
      use Cqrs.Message,
          [require_all_fields?: false]
          |> Keyword.merge(unquote(opts))
          |> Keyword.put(:message_type, :value_object)
    end
  end
end
