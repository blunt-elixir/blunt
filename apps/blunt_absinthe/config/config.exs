import Config

config :blunt, :context_shipper, Blunt.Absinthe.Test.DispatchContextShipper

config :logger, :console, format: "[$level] $message\n", level: :warning
