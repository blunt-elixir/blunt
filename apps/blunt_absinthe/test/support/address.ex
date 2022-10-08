defmodule Blunt.Absinthe.Test.Address do
  use Blunt.ValueObject
  import Ecto.Changeset

  field :line1, :string, required: true
  field :line2, :string

  @impl true
  def handle_validate(changeset, _opts) do
    changeset
    |> validate_length(:line1, min: 3)
    |> validate_format(:line1, ~r/(\d)+.*/, message: "should start with a number")
  end
end
