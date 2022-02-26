defmodule Blunt.Repo do
  use Ecto.Repo, otp_app: :blunt_bounded_context, adapter: Etso.Adapter
end
