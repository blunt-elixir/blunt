import Config

# ###################################################################
# This is an example of all the configuration settings in Blunt.
#
# The values set here are for testing the libraries.
# They are *not* recommendations.
# ###################################################################
config :blunt,
  log_when_compiling: false,
  dispatch_return: :response,
  documentation_output: false,
  create_jason_encoders: false,
  context_shipper: Blunt.Test.ContextShipper,
  dispatch_strategy: Blunt.DispatchStrategy.Default,
  pipeline_resolver: Blunt.DispatchStrategy.PipelineResolver.Default,
  dispatch_context_configuration: Blunt.DispatchContext.DefaultConfiguration,
  schema_field_definitions: [
    Blunt.Test.FieldTypes.EmailField
  ],
  schema_field_providers: [
    Blunt.Test.FieldTypes.EmailField,
    Blunt.Test.FieldTypes.UuidField
  ]

config :blunt_absinthe,
  dispatch_context_configuration: Blunt.Absinthe.Test.DispatchContextConfiguration

config :blunt_absinthe_relay, :repo, Blunt.Repo

# ###################################################################
# BELOW HERE BE FOR INTERNAL TESTING ONLY
# ###################################################################
config :logger, :console, format: "[$level] $message\n", level: :warning

config :blunt_toolkit, TestEventStore,
  column_data_type: "jsonb",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "cqrs_toolkit_eventstore",
  serializer: EventStore.JsonbSerializer,
  types: EventStore.PostgresTypes

config :eventstore, :event_stores, [EventStore]
