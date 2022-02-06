defmodule Cqrs.Message.Type.Pid do
  use Ecto.Type

  def type, do: :any

  def cast(pid) when is_pid(pid),
    do: {:ok, pid}

  def cast(value) when is_binary(value) do
    {:ok, :erlang.list_to_pid(value)}
  rescue
    _ -> {:error, [message: "is not a valid Pid"]}
  end

  def load(value) when is_list(value),
    do: {:ok, :erlang.list_to_pid(value)}

  def dump(pid) when is_pid(pid),
    do: {:ok, :erlang.pid_to_list(pid)}
end
