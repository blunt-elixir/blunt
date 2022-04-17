defmodule Blunt.Absinthe.Test.UpdatePerson do
  use Blunt.Command
  alias Blunt.Absinthe.Test.ReadModel.Person

  field :id, :binary_id
  field :name, :string
  field :gender, :enum, values: Person.genders(), required: false
end
