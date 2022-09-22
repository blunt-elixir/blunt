defmodule Blunt.Telemetry do
  def start(event_prefix, metadata \\ %{}, additional_measurements \\ %{}) do
    start_time = System.monotonic_time()
    measurements = Map.put(additional_measurements, :system_time, System.system_time())
    :telemetry.execute(event_prefix ++ [:start], measurements, metadata)
    start_time
  end

  def stop(event_prefix, start_time, metadata \\ %{}, additional_measurements \\ %{}) do
    measurements = include_duration(start_time, additional_measurements)
    :telemetry.execute(event_prefix ++ [:stop], measurements, metadata)
  end

  defp include_duration(start_time, measurements) do
    end_time = System.monotonic_time()
    Map.put(measurements, :duration, end_time - start_time)
  end
end
