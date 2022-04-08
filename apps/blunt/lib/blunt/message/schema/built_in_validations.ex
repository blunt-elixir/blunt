defmodule Blunt.Message.Schema.BuiltInValidations do
  @moduledoc false

  def run({:require_at_least_one, fields}, changeset) do
    import Ecto.Changeset, only: [get_change: 2, add_error: 3]

    supplied = fields |> Enum.map(&get_change(changeset, &1)) |> Enum.reject(&is_nil/1)

    error = "expected at least one of following fields to be supplied: #{inspect(fields)}"

    case supplied do
      [] -> add_error(changeset, :fields, error)
      _ -> changeset
    end
  end

  def run({:require_either, fields}, changeset) do
    import Ecto.Changeset, only: [get_change: 2, add_error: 3]

    supplied =
      fields
      |> Enum.flat_map(fn
        field when is_atom(field) -> [get_change(changeset, field)]
        fields when is_list(fields) -> Enum.map(fields, &get_change(changeset, &1))
      end)
      |> Enum.reject(&is_nil/1)

    expected_fields =
      fields
      |> Enum.map(fn
        field when is_atom(field) ->
          inspect(field)

        fields when is_list(fields) ->
          message = Enum.map(fields, &inspect/1) |> Enum.join(" AND ")
          "(" <> message <> ")"
      end)
      |> Enum.join(" OR ")

    error = "expected either #{expected_fields} to be present"

    case supplied do
      [] -> add_error(changeset, :fields, error)
      _ -> changeset
    end
  end
end
