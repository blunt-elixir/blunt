defmodule Cqrs.DispatchStrategy.HandlerResolver.Default do
  @behaviour Cqrs.DispatchStrategy.HandlerResolver

  @moduledoc """
  Resolves `CommandHandler`s and `QueryHandler`s by convention.

  Handler modules are meant to be named "Namespace.MessageHandler".
  That is, the message module with "Handler" appended to the end.
  """

  alias Cqrs.Behaviour

  @type handler :: atom()
  @type message_module :: atom()
  @type behaviour_module :: atom()

  @spec resolve(message_module(), behaviour_module()) :: {:ok, handler()} | :error

  def resolve(message_module, behaviour_module) do
    with {:ok, handler_module} <- resolve_module(message_module) do
      Behaviour.validate(handler_module, behaviour_module)
    end
  end

  defp resolve_module(module) do
    {:ok, String.to_existing_atom(to_string(module) <> "Handler")}
  rescue
    _ -> :error
  end
end
