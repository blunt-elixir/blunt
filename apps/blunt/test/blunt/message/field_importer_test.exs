defmodule Blunt.Message.FieldImporterTest do
  use ExUnit.Case

  alias Blunt.Message.Metadata

  defmodule One do
    use Blunt.Command, create_jason_encoders?: false

    field :id, :integer
    field :one, :string
  end

  defmodule Two do
    use Blunt.Command, create_jason_encoders?: false

    field :id, :integer
    field :two, :string
  end

  defmodule Three do
    use Blunt.Command, create_jason_encoders?: false

    field :id, :integer
    field :three, :string

    import_fields(One, only: [:one])

    import_fields(Two,
      except: [:id],
      transform: fn {name, type, opts} ->
        name = to_string(name)

        [
          {String.to_atom(name <> "_a"), type, opts},
          {String.to_atom(name <> "_b"), type, opts}
        ]
      end
    )
  end

  test "three has all imported fields" do
    assert [:discarded_data, :id, :one, :three, :two_a, :two_b] ==
             Metadata.field_names(Three)
             |> Enum.sort()
  end
end
