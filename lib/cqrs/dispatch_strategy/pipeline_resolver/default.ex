defmodule Cqrs.DispatchStrategy.PipelineResolver.Default do
  @behaviour Cqrs.DispatchStrategy.PipelineResolver

  @moduledoc """
  Resolves `CommandPipeline`s and `QueryPipeline`s by convention.

  Pipeline modules are meant to be named "Namespace.MessagePipeline".
  That is, the message module with "Pipeline" appended to the end.
  """

  alias Cqrs.Behaviour

  @type pipeline :: atom()
  @type message_module :: atom()
  @type behaviour_module :: atom()

  @spec resolve(message_module(), behaviour_module()) :: {:ok, pipeline()} | :error

  def resolve(message_module, behaviour_module) do
    with {:ok, pipeline_module} <- resolve_module(message_module) do
      Behaviour.validate(pipeline_module, behaviour_module)
    end
  end

  defp resolve_module(module) do
    {:ok, String.to_existing_atom(to_string(module) <> "Pipeline")}
  rescue
    _ -> :error
  end
end
