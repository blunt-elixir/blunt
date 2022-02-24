defmodule Blunt.Repo do
  use Ecto.Repo, otp_app: :blunt, adapter: Etso.Adapter
end
