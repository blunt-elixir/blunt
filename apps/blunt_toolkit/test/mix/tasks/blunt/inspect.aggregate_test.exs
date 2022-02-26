defmodule Mix.Tasks.Blunt.Inspect.AggregateTest do
  use EventStoreCase, async: false

  use Blunt.Testing.ExMachina
  use AppendToStreamStrategy

  @person_id "25d85f07-26ab-4434-851b-d11da9ec942e"

  factory PersonCreated
  factory PersonUpdated

  test "populate some events" do
    data = %{id: @person_id}
    opts = [stream_uuid: "person-" <> @person_id]

    append_to_stream(:person_created, data, opts)
    append_to_stream_list(50, :person_updated, data, opts)
  end
end
