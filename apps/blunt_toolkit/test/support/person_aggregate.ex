defmodule PersonAggregate do
  defstruct [:id, :name]

  def apply(state, %PersonCreated{id: id, name: name}) do
    %{state | id: id, name: name}
  end

  def apply(state, %PersonUpdated{name: name}) do
    %{state | name: name}
  end
end
