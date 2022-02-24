defmodule Support.Testing.PlainMessage do
  use Blunt.Message

  field :id, :binary_id
  field :name, :string
end
