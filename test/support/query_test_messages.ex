defmodule Cqrs.QueryTest.Protocol do
  defmodule BasicQuery do
    use Cqrs.Query

    @moduledoc """
    Illustrates the basic idea of a Query
    """

    field :id, :binary_id
    field :name, :string
  end

  defmodule CreatePerson do
    use Cqrs.Command

    field :name, :string
    field :id, :binary_id, required: false

    def after_validate(command),
      do: %{command | id: UUID.uuid4()}
  end

  defmodule GetPerson do
    use Cqrs.Query

    alias Cqrs.QueryTest.ReadModel.Person

    field :id, :binary_id
    field :name, :string

    binding :person, Person
  end
end
