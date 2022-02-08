defmodule Cqrs.DispatchStrategy do
  alias Cqrs.{Behaviour, DispatchContext}

  @type context :: DispatchContext.t()
  @type dispatch_return :: {:ok, context() | any()} | {:error, context()}

  @callback dispatch(context()) :: dispatch_return()

  @spec dispatch(context()) :: dispatch_return()

  def dispatch(context) do
    get_strategy().dispatch(context)
  end

  defp get_strategy do
    :cqrs_tools
    |> Application.get_env(:dispatch_strategy, __MODULE__.Default)
    |> Behaviour.validate!(__MODULE__)
  end

  @spec return_last_pipeline(context()) :: {:ok, any}
  def return_last_pipeline(context) do
    context
    |> DispatchContext.get_last_pipeline()
    |> return_final(context)
  end

  @spec return_final(any, context()) :: {:ok, any}
  def return_final(value, context) do
    case DispatchContext.get_return(context) do
      :context -> {:ok, context}
      _ -> {:ok, value}
    end
  end

  @spec execute({atom, atom, list}, context()) :: {:error, context()} | {:ok, context()}
  def execute({pipeline, callback, args}, context) do
    case apply(pipeline, callback, args) do
      {:error, error} ->
        {:error,
         context
         |> DispatchContext.put_error(error)
         |> DispatchContext.put_pipeline(callback, {:error, error})}

      :error ->
        {:error,
         context
         |> DispatchContext.put_error(:error)
         |> DispatchContext.put_pipeline(callback, :error)}

      {:ok, %DispatchContext{} = context} ->
        {:ok, DispatchContext.put_pipeline(context, callback, :ok)}

      {:ok, {:ok, response}} ->
        {:ok, DispatchContext.put_pipeline(context, callback, response)}

      {:ok, response} ->
        {:ok, DispatchContext.put_pipeline(context, callback, response)}

      response ->
        {:ok, DispatchContext.put_pipeline(context, callback, response)}
    end
  end
end
