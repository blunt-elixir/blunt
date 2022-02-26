defmodule Blunt.Absinthe.Test.SchemaTypes do
  use Blunt.Absinthe
  use Absinthe.Schema.Notation

  alias Blunt.Absinthe.Test.{CreatePerson, GetPerson}

  derive_enum :gender, {CreatePerson, :gender}

  object :person do
    field :id, :id
    field :name, :string
    field :gender, :gender
  end

  object :person_queries do
    derive_query GetPerson, :person,
      arg_transforms: [
        id: &Function.identity/1
      ]
  end

  object :person_mutations do
    derive_mutation CreatePerson, :person, arg_types: [gender: :gender]
  end
end
