defmodule Blunt.Message.Type.Atom do
  @moduledoc false

  use Ecto.Type

  def type, do: :any

  def cast(nil), do: {:ok, nil}

  def cast(atom) when is_atom(atom),
    do: {:ok, atom}

  def cast(_other), do: :error

  def load(nil), do: {:ok, nil}

  def load(value) when is_binary(value),
    do: {:ok, String.to_existing_atom(value)}

  def dump(nil), do: {:ok, nil}

  def dump(value) when is_atom(value),
    do: {:ok, to_string(value)}
end
