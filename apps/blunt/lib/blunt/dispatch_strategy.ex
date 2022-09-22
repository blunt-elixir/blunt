defmodule Blunt.DispatchStrategy do
  use TelemetryRegistry
  alias Blunt.{Config, DispatchContext, Telemetry}

  telemetry_event(%{
    event: [:blunt, :dispatch_strategy, :execute, :start],
    description: "Emitted when a message dispatch is started",
    measurements: "%{system_time: integer()}",
    metadata: """
    """
  })

  telemetry_event(%{
    event: [:blunt, :dispatch_strategy, :execute, :stop],
    description: "Emitted when a message dispatch is finished",
    measurements: "%{duration: non_neg_integer()}",
    metadata: """
    """
  })

  @type context :: DispatchContext.t()

  @callback dispatch(context()) :: {:ok, context() | any()} | {:error, context()}

  def dispatch(context) do
    %{message: %{__struct__: message_type} = message} = context

    start_time =
      telemetry_start([:blunt, :dispatch_strategy, :execute], %{
        message_type: message_type,
        message: message
      })

    result = Config.dispatch_strategy!().dispatch(context)
    telemetry_stop([:blunt, :dispatch_strategy, :execute], start_time, %{}, result)
    result
  end

  defp telemetry_start(event_prefix, telemetry_metadata) do
    Telemetry.start(event_prefix, telemetry_metadata)
  end

  defp telemetry_stop(event_prefix, start_time, telemetry_metadata, result) do
    telemetry_metadata =
      case result do
        {:ok, %DispatchContext{} = context} ->
          Map.put(telemetry_metadata, :context, context)

        {:ok, result} ->
          Map.put(telemetry_metadata, :result, result)

        {:error, %DispatchContext{} = context} ->
          errors = DispatchContext.errors(context)

          telemetry_metadata
          |> Map.put(:error, errors)
          |> Map.put(:context, context)

        {:error, error} ->
          Map.put(telemetry_metadata, :error, error)

        %DispatchContext{} = context ->
          Map.put(telemetry_metadata, :context, context)

        result ->
          Map.put(telemetry_metadata, :result, result)
      end

    do_telemetry_stop(event_prefix, start_time, telemetry_metadata)
  end

  defp do_telemetry_stop(event_prefix, start_time, telemetry_metadata) do
    Telemetry.stop(event_prefix, start_time, telemetry_metadata)
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

  @spec execute({module :: atom, function :: atom, args :: list}, context()) :: {:error, context()} | {:ok, context()}
  def execute({pipeline, callback, args}, context) do
    start_time = telemetry_start([:blunt, :dispatch_strategy, callback, :start], context)
    result = do_execute({pipeline, callback, args}, context)
    telemetry_stop([:blunt, :dispatch_strategy, callback, :stop], start_time, result, result)
    result
  end

  defp do_execute({pipeline, callback, args}, context) do
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
    case Config.error_return() do
      :context -> context
      :errors -> DispatchContext.errors(context)
    end
  end
end
