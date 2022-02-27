defmodule Support.StateTest.Protocol.PersonCreated do
  use Blunt.Message, require_all_fields?: true

  field :id, :binary_id
  field :name, :string
end
