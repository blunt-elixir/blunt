import Config

config :blunt_absinthe,
  dispatch_context_configuration: Blunt.Absinthe.Relay.Test.DispatchContextConfiguration

config :blunt_absinthe_relay, :repo, Blunt.Repo

config :blunt, :context_shipper, Blunt.Absinthe.Relay.Test.PublishingDispatchContextShipper
