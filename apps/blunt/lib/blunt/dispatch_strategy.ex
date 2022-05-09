defmodule Blunt.DispatchStrategy do
  alias Blunt.{Config, DispatchContext}

  @type context :: DispatchContext.t()

  @callback dispatch(context()) :: {:ok, context() | any()} | {:error, context()}

  def dispatch(context) do
    Config.dispatch_strategy!().dispatch(context)
  end

  @spec return_last_pipeline(context()) :: {:ok, any}
  def return_last_pipeline(context) do
    context
    |> DispatchContext.get_last_pipeline()
    |> return_final(context)
  end

  @spec return_final(any, context()) :: {:ok, any}
  def return_final(value, context) do
    if DispatchContext.get_option(context, :ship, true),
      do: DispatchContext.Shipper.ship(context)

    case DispatchContext.get_return(context) do
      :context -> {:ok, context}
      _ -> {:ok, value}
    end
  end

  @spec execute({module :: atom, function :: atom, args :: list}, context()) :: {:error, context()} | {:ok, context()}
  def execute({pipeline, callback, args}, context) do
    case apply(pipeline, callback, args) do
      {:error, %DispatchContext{} = context} ->
        {:error, translate_errors(context)}

      {:error, error} ->
        {:error,
         context
         |> DispatchContext.put_error(error)
         |> DispatchContext.put_pipeline(callback, {:error, error})
         |> translate_errors()}

      :error ->
        {:error,
         context
         |> DispatchContext.put_error(:error)
         |> DispatchContext.put_pipeline(callback, :error)
         |> translate_errors()}

      {:ok, %DispatchContext{} = context} ->
        result = DispatchContext.get_last_pipeline(context)
        {:ok, DispatchContext.put_pipeline(context, callback, result)}

      {:ok, {:ok, response}} ->
        {:ok, DispatchContext.put_pipeline(context, callback, response)}

      {:ok, response} ->
        {:ok, DispatchContext.put_pipeline(context, callback, response)}

      %DispatchContext{} = context ->
        {:ok, context}

      response ->
        {:ok, DispatchContext.put_pipeline(context, callback, response)}
    end
  end

  defp translate_errors(context) do
    case DispatchContext.get_return(context) do
      :context -> context
      _ -> DispatchContext.errors(context)
    end
  end
end
