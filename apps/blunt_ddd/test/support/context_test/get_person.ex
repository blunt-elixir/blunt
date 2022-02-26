defmodule Support.ContextTest.GetPerson do
  use Blunt.Query

  field :id, :binary_id, required: true

  binding :person, CqrsToolsContext.QueryTest.ReadModel.Person
end
