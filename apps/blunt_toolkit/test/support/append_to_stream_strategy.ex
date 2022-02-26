defmodule AppendToStreamStrategy do
  use ExMachina.Strategy, function_name: :append_to_stream

  alias EventStore
  alias EventStore.EventData
  alias Blunt.Message.Metadata

  def handle_append_to_stream(event, %{stream_uuid: stream_uuid}),
    do: handle_append_to_stream(event, %{}, stream_uuid: stream_uuid)

  def handle_append_to_stream(event, strategy_opts),
    do: handle_append_to_stream(event, strategy_opts, [])

  def handle_append_to_stream(%{__struct__: module} = event, _strategy_opts, opts) do
    fields = Metadata.field_names(module)
    event = struct!(module, Map.take(event, fields))
    stream_uuid = Keyword.fetch!(opts, :stream_uuid)

    TestEventStore.append_to_stream(stream_uuid, :any_version, [%EventData{data: event}])
  end
end
