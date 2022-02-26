defmodule Blunt.Message.Type.Pid do
  @moduledoc false

  use Ecto.Type

  def type, do: :any

  def cast(pid) when is_pid(pid),
    do: {:ok, pid}

  def cast(string) when is_binary(string),
    do: {:error, [message: "is not a valid Pid"]}

  def cast(value) when is_list(value) do
    {:ok, :erlang.list_to_pid(value)}
  rescue
    _ -> {:error, [message: "is not a valid Pid"]}
  end

  def load(value) when is_list(value),
    do: {:ok, :erlang.list_to_pid(value)}

  def dump(pid) when is_pid(pid),
    do: {:ok, :erlang.pid_to_list(pid)}
end
