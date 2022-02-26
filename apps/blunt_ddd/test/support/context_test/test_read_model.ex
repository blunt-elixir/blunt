defmodule Support.ContextTest.ReadModel do
  defmodule Person do
    use Ecto.Schema

    @primary_key {:id, :binary_id, autogenerate: false}
    schema "people" do
      field :name, :string
    end

    def changeset(person \\ %__MODULE__{}, attrs) do
      person
      |> Ecto.Changeset.cast(attrs, [:id, :name])
      |> Ecto.Changeset.validate_required([:id])
    end
  end
end
