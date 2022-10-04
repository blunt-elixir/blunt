defmodule Blunt.Absinthe.Test.SchemaTypes do
  use Blunt.Absinthe
  use Absinthe.Schema.Notation

  alias Blunt.Absinthe.Test.{CreatePerson, GetPerson, UpdatePerson, Address, Dog}

  derive_enum :gender, {CreatePerson, :gender}

  object :person do
    field :id, :id
    field :name, :string
    field :gender, :gender
    field :address, :address
  end

  derive_object(:dog, Dog)
  derive_object(:address, Address)
  derive_mutation_input Address

  object :person_queries do
    derive_query GetPerson, :person,
      arg_transforms: [
        id: &Function.identity/1
      ]
  end

  derive_mutation_input(UpdatePerson, arg_types: [gender: :gender])

  object :person_mutations do
    derive_mutation CreatePerson, :person, arg_types: [gender: :gender, address: :address_input]
    derive_mutation UpdatePerson, :person, input_object: true
  end
end
