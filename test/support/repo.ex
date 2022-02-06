defmodule Cqrs.Repo do
  use Ecto.Repo, otp_app: :cqrs_tools, adapter: Etso.Adapter
end
