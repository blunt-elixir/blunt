defmodule Cqrs.DispatchStrategy.PipelineResolver.Default do
  @behaviour Cqrs.DispatchStrategy.PipelineResolver

  @moduledoc """
  Resolves `CommandPipeline`s and `QueryPipeline`s by convention.

  Pipeline modules are meant to be named "Namespace.MessagePipeline".
  That is, the message module with "Pipeline" appended to the end.
  """

  @type pipeline_module :: atom()
  @type message_module :: atom()

  @spec resolve(message_module()) :: {:ok, pipeline_module()} | :error

  def resolve(message_module) do
    {:ok, String.to_existing_atom(to_string(message_module) <> "Pipeline")}
  rescue
    _ -> :error
  end
end
