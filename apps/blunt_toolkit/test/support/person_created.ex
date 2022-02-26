defmodule PersonCreated do
  use Blunt.DomainEvent

  field :id, :binary_id
  field :name, :string
end
