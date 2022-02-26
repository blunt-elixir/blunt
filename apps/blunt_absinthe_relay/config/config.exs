import Config

config :blunt_absinthe_relay, :repo, Blunt.Repo
config :blunt, :context_shipper, Blunt.Absinthe.Relay.Test.DispatchContextShipper
