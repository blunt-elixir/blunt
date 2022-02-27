import Config

config :blunt, context_shipper: Blunt.Absinthe.Test.PublishingDispatchContextShipper

config :blunt_absinthe,
  dispatch_context_configuration: Blunt.Absinthe.Test.DispatchContextConfiguration

config(:logger, :console, format: "[$level] $message\n", level: :warning)
