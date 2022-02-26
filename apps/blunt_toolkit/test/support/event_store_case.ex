defmodule EventStoreCase do
  use ExUnit.CaseTemplate

  alias EventStore.{Config, Storage, Tasks}

  setup_all do
    event_store = TestEventStore

    config = Config.parsed(event_store, :blunt_toolkit)

    postgrex_config = Config.default_postgrex_opts(config)

    Tasks.Create.exec(config, quiet: true)
    Tasks.Init.exec(config, quiet: true)
    Tasks.Migrate.exec(config, quiet: true)

    conn = start_supervised!({Postgrex, postgrex_config})

    [conn: conn, config: config, event_store: event_store]
  end

  setup %{conn: conn, config: config, event_store: event_store} do
    Storage.Initializer.reset!(conn, config)

    start_supervised!(event_store)

    :ok
  end
end
