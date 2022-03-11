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
end
