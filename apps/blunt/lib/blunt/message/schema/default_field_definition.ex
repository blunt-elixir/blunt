defmodule Blunt.Message.Schema.DefaultFieldDefinition do
  use Blunt.Message.Schema.FieldDefinition

  alias Blunt.Message.Type.{Atom, Pid}

  def define(:atom, opts), do: {Atom, opts}
  def define(:pid, opts), do: {Pid, opts}
end
