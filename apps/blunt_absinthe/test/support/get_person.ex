defmodule Blunt.Absinthe.Test.GetPerson do
  use Blunt.Query

  @moduledoc """
  Get's a person.
  """

  field :id, :binary_id, required: true

  field :error_out, :boolean, default: false

  binding :person, BluntBoundedContext.QueryTest.ReadModel.Person
end
