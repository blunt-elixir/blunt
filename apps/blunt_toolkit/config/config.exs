import Config

config :logger, level: :warn

config :blunt_toolkit, TestEventStore,
  column_data_type: "jsonb",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "cqrs_toolkit_eventstore",
  serializer: EventStore.JsonbSerializer,
  types: EventStore.PostgresTypes

config :eventstore, :event_stores, [EventStore]
