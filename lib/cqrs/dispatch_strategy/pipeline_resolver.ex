defmodule Cqrs.DispatchStrategy.PipelineResolver do
  alias Cqrs.{Behaviour, Config, DispatchContext}

  defmodule Error do
    defexception [:message]
  end

  @type message_type :: atom()
  @type message_module :: atom()
  @type pipeline_module :: atom()
  @type behaviour_module :: atom()
  @type context :: DispatchContext.command_context() | DispatchContext.query_context()

  @callback resolve(message_type, message_module) :: {:ok, pipeline_module} | :error

  @spec get_pipeline!(context, behaviour_module) :: pipeline_module
  @spec get_pipeline(context, behaviour_module) :: {:ok, pipeline_module} | {:error, String.t()} | :error

  @doc false
  def get_pipeline(%{message_type: type, message_module: message_module}, behaviour_module) do
    with {:ok, pipeline_module} <- Config.pipeline_resolver!().resolve(type, message_module) do
      Behaviour.validate(pipeline_module, behaviour_module)
    end
  end

  @doc false
  def get_pipeline!(%{message_module: message_module} = context, behaviour_module) do
    case get_pipeline(context, behaviour_module) do
      {:ok, pipeline} -> pipeline
      {:error, reason} -> raise Error, message: reason
      :error -> raise Error, message: "No #{inspect(behaviour_module)} found for query: #{inspect(message_module)}"
    end
  end
end
