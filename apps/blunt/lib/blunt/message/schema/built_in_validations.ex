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

  def run({:require_exactly_one, fields}, changeset) do
    import Ecto.Changeset, only: [get_change: 2, add_error: 3]

    provided_fields =
      fields
      |> Enum.map(&get_change(changeset, &1))
      |> Enum.reject(&is_nil/1)

    case provided_fields do
      [_field] ->
        changeset

      _ ->
        fields =
          fields
          |> Enum.sort()
          |> Enum.map(&inspect/1)
          |> Enum.join(" OR ")

        add_error(changeset, :fields, "expected exactly one of #{fields} to be provided")
    end
  end

  def run({:require_either, fields}, changeset) do
    import Ecto.Changeset, only: [get_change: 2, add_error: 3]

    no_required_fields_supplied =
      fields
      |> Enum.map(fn
        field when is_atom(field) -> [get_change(changeset, field)]
        fields when is_list(fields) -> Enum.map(fields, &get_change(changeset, &1))
      end)
      |> Enum.map(fn changes ->
        Enum.any?(changes, &is_nil/1)
      end)
      |> Enum.all?(&(&1 == true))

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

    if no_required_fields_supplied do
      error = "expected either #{expected_fields} to be present"
      add_error(changeset, :fields, error)
    else
      changeset
    end
  end
end
