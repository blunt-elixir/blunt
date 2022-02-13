defmodule Support.Testing.PlainMessage do
  use Cqrs.Message

  field :id, :binary_id
  field :name, :string
end
