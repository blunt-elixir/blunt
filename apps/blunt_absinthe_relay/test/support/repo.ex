defmodule Blunt.Repo do
  use Ecto.Repo, otp_app: :blunt_absinthe_relay, adapter: Etso.Adapter
end
