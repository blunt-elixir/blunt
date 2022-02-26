defmodule Blunt.Absinthe.Test.CreatePerson do
  @moduledoc """
  Creates's a person.
  """

  use Blunt.Command
  alias Blunt.Absinthe.Test.ReadModel.Person

  field :name, :string
  field :gender, :enum, values: Person.genders(), default: :not_sure

  internal_field :id, :binary_id, desc: "Id is set internally. Setting it will have no effect"

  option :send_notification, :boolean, default: false

  @impl true
  def after_validate(command) do
    Map.put(command, :id, UUID.uuid4())
  end
end
