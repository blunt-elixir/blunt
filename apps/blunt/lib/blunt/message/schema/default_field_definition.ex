defmodule Blunt.Message.Schema.DefaultFieldDefinition do
  @behaviour Blunt.Message.Schema.FieldDefinition

  alias Blunt.Message.Type.{Atom, Pid}

  def define(:atom, opts), do: {Atom, opts}
  def define(:pid, opts), do: {Pid, opts}
  def define(:enum, opts), do: {Ecto.Enum, opts}
  def define(:binary_id, opts), do: {Ecto.UUID, opts}
  def define(type, opts), do: {type, opts}

  def fake(:atom), do: :fake_atom
  def fake(:pid), do: :c.pid(0, 250, 0)
  def fake(:enum), do: nil
  def fake(:binary_id), do: Ecto.UUID.generate()
end
