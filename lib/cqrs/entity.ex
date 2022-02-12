defmodule Cqrs.Entity do
  alias Cqrs.Entity.Identity

  defmodule Error do
    defexception [:message]
  end

  defmacro __using__(opts) do
    quote do
      {identity, opts} = Identity.pop(unquote(opts))

      use Cqrs.Message,
          [require_all_fields?: true]
          |> Keyword.merge(unquote(opts))
          |> Keyword.put(:dispatch?, false)
          |> Keyword.put(:message_type, :entity)
          |> Keyword.put(:primary_key, Macro.escape(identity))
    end
  end
end
