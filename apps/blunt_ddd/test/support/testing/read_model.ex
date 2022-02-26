defmodule Support.Testing.ReadModel do
  defmodule Person do
    use Ecto.Schema

    @genders [:male, :female, :not_sure]
    def genders, do: @genders

    @primary_key {:id, :binary_id, autogenerate: false}
    schema "people" do
      field :name, :string
      field :gender, Ecto.Enum, values: @genders, default: :not_sure
    end

    def changeset(person \\ %__MODULE__{}, attrs) do
      person
      |> Ecto.Changeset.cast(attrs, [:id, :name, :gender])
      |> Ecto.Changeset.validate_required([:id, :gender])
    end
  end
end
