defmodule OpentelemetryBlunt do
  @tracer_id __MODULE__

  def setup do
    attach_dispatch_start_handler()
    attach_dispatch_stop_handler()
  end

  defp attach_dispatch_start_handler do
    :telemetry.attach(
      "#{__MODULE__}.dispatch_start",
      [:blunt, :dispatch_strategy, :execute, :start],
      &__MODULE__.handle_start/4,
      []
    )
  end

  defp attach_dispatch_stop_handler do
    :telemetry.attach(
      "#{__MODULE__}.dispatch_stop",
      [:blunt, :dispatch_strategy, :execute, :stop],
      &__MODULE__.handle_stop/4,
      []
    )
  end

  def handle_start(_event, _measurements, metadata, _config) do
    parent = OpenTelemetry.Tracer.current_span_ctx()
    links = if parent == :undefined, do: [], else: [OpenTelemetry.link(parent)]
    OpenTelemetry.Tracer.set_current_span(:undefined)

    OpentelemetryTelemetry.start_telemetry_span(@tracer_id, "blunt.dispatch", metadata, %{
      kind: :consumer,
      links: links,
      attributes: metadata
    })
  end

  def handle_stop(_event, _measurements, metadata, _config) do
    OpentelemetryTelemetry.end_telemetry_span(@tracer_id, metadata)
  end

  defp read_metadata(%Blunt.DispatchContext{} = context) do
  end

  defp read_metadata(metadata), do: metadata
end
