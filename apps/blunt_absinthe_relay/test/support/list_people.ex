defmodule Blunt.Absinthe.Relay.Test.ListPeople do
  use Blunt.Query
  alias Blunt.Absinthe.Relay.Test.Person

  field :name, :string
  field :gender, :enum, values: Person.genders()

  binding :person, Person
end
