defmodule Blunt.Message.Type.Atom do
  @moduledoc false

  use Ecto.Type

  def type, do: :any

  def cast(atom) when is_atom(atom),
    do: {:ok, atom}

  # def cast(string) when is_binary(string),
  #   do: {:ok, String.to_existing_atom(string)}

  def load(value) when is_binary(value),
    do: {:ok, String.to_existing_atom(value)}

  def dump(value) when is_atom(value),
    do: {:ok, to_string(value)}
end
