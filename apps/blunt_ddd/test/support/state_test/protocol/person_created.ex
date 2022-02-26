defmodule Support.StateTest.Protocol.PersonCreated do
  use Blunt.DomainEvent, require_all_fields?: true

  field :id, :binary_id
  field :name, :string
end
