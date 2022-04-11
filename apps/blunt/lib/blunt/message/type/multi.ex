defmodule Blunt.Message.Type.Multi do
  use Ecto.Type

  def type, do: :any

  def cast(value) when is_struct(value, Ecto.Multi),
    do: {:ok, value}

  def load(value) when is_map(value),
    do: {:ok, struct!(Ecto.Multi, value)}

  def dump(value) when is_map(value),
    do: {:ok, Map.from_struct(value)}
end
