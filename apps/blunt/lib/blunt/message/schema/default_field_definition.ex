defmodule Blunt.Message.Schema.DefaultFieldDefinition do
  @behaviour Blunt.Message.Schema.FieldDefinition

  alias Blunt.Message.Type.{Atom, Pid}

  def define(:atom, opts), do: {Atom, opts}
  def define(:pid, opts), do: {Pid, opts}
  def define(:enum, opts), do: {Ecto.Enum, opts}
  def define(:binary_id, opts), do: {Ecto.UUID, opts}
  def define(type, opts), do: {type, opts}
end
