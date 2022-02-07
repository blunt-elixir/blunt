defmodule Cqrs.DispatchStrategy.PipelineResolver do
  alias Cqrs.{Behaviour, DispatchContext}

  defmodule Error do
    defexception [:message]
  end

  @type pipeline :: atom()
  @type message_module :: atom()
  @type behaviour_module :: atom()
  @type context :: DispatchContext.command_context() | DispatchContext.query_context()

  @callback resolve(message_module, behaviour_module) :: {:ok, pipeline} | :error

  @spec get_pipeline!(context, behaviour_module) :: pipeline
  @spec get_pipeline(context, behaviour_module) :: {:ok, pipeline} | {:error, any()} | :error

  @doc false
  def get_pipeline(%{message: %{__struct__: module}}, behaviour_module) do
    resolver().resolve(module, behaviour_module)
  end

  @doc false
  def get_pipeline!(%{message: %{__struct__: module}} = context, behaviour_module) do
    case get_pipeline(context, behaviour_module) do
      {:ok, pipeline} -> pipeline
      {:error, reason} -> raise Error, message: reason
      :error -> raise Error, message: "No #{inspect(behaviour_module)} found for query: #{inspect(module)}"
    end
  end

  defp resolver do
    :cqrs_tools
    |> Application.get_env(:pipeline_resolver, __MODULE__.Default)
    |> Behaviour.validate!(__MODULE__)
  end
end
