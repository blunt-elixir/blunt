defmodule Blunt.DispatchStrategy.PipelineResolver.Default do
  @behaviour Blunt.DispatchStrategy.PipelineResolver

  @moduledoc """
  Resolves `CommandHandler`s and `QueryHandler`s by convention.

  Handler modules are meant to be named "Namespace.MessageHandler".
  That is, the message module with "Handler" appended to the end.
  """

  @type message_type :: atom()
  @type message_module :: atom()
  @type pipeline_module :: atom()

  @spec resolve(message_type(), message_module()) :: {:ok, pipeline_module()} | :error

  def resolve(_message_type, message_module) do
    {:ok, String.to_existing_atom(to_string(message_module) <> "Handler")}
  rescue
    _ -> :error
  end
end
