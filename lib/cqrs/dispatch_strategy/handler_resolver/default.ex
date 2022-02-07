defmodule Cqrs.DispatchStrategy.HandlerResolver.Default do
  @behaviour Cqrs.DispatchStrategy.HandlerResolver

  @moduledoc """
  Resolves `CommandHandler`s and `QueryHandler`s by convention.

  Handler modules are meant to be named "Namespace.MessageHandler".
  That is, the message module with "Handler" appended to the end.
  """

  alias Cqrs.Behaviour
  alias Cqrs.DispatchStrategy.HandlerResolver

  @type handler :: HandlerResolver.handler()
  @type message_module :: HandlerResolver.message_module()
  @type behaviour_module :: HandlerResolver.behaviour_module()

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
