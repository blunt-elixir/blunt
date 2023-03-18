defmodule BluntCommanded.Test.Protocol.UpdateUser do
  use Blunt.Command
  use Blunt.Command.EventDerivation

  field :id, :binary_id
  field :name, :string

  # sample enrichment field. See BluntCommanded.Test.Protocol.UpdateUser.Enrichment
  internal_field :date, :utc_datetime

  derive_event UserUpdated
end
