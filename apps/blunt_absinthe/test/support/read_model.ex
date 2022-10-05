defmodule Blunt.Absinthe.Test.ReadModel do
  defmodule Person do
    use Ecto.Schema

    @genders [:male, :female, :not_sure]
    def genders, do: @genders

    @primary_key {:id, :binary_id, autogenerate: false}
    schema "people" do
      field :name, :string
      field :gender, Ecto.Enum, values: @genders, default: :not_sure

      embeds_one :address, Address, primary_key: false do
        field :line1, :string
        field :line2, :string
      end
    end

    def changeset(person \\ %__MODULE__{}, attrs) do
      person
      |> Ecto.Changeset.cast(attrs, [:id, :name, :gender])
      |> Ecto.Changeset.validate_required([:id, :gender])
      |> Ecto.Changeset.cast_embed(:address, with: &address_changeset/2)
    end

    def address_changeset(address, attrs) do
      address
      |> Ecto.Changeset.cast(attrs, [:line1, :line2])
    end
  end
end
