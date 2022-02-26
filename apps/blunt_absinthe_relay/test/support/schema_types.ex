defmodule Blunt.Absinthe.Relay.Test.SchemaTypes do
  use Blunt.{Absinthe, Absinthe.Relay}
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  alias Blunt.Absinthe.Relay.Test.ListPeople

  derive_enum :gender, {ListPeople, :gender}

  object :person do
    field :id, :id
    field :name, :string
    field :gender, :gender
  end

  define_connection(:person, total_count: true)

  object :person_queries do
    derive_connection ListPeople, :person, arg_types: [gender: :gender]
  end
end
