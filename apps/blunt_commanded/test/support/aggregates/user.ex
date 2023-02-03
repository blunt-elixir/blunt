defmodule BluntCommanded.Test.Aggregates.User do
  defstruct [:id, :name]

  alias BluntCommanded.Test.Protocol.{CreateUser, UserCreated}
  alias BluntCommanded.Test.Protocol.{UpdateUser, UserUpdated}

  def execute(%{id: nil}, %CreateUser{} = command) do
    UserCreated.new(command)
  end

  def execute(_state, _command) do
    {:error, "user not found"}
  end

  def execute(%{id: id}, %UpdateUser{} = command) do
    UserUpdated.new(command)
  end

  def apply(state, %UserCreated{id: id, name: name}) do
    %{state | id: id, name: name}
  end

  def apply(state, %UserUpdated{name: name}) do
    %{state | name: name}
  end
end
