defmodule Blunt.Message.State do
  use DynamicSupervisor

  def start_link(opts) do
    DynamicSupervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def put(%{__blunt_id: id}, value) when is_map(value),
    do: put(id, value)

  def put(id, value) when is_map(value) do
    id
    |> get_or_start_server()
    |> __MODULE__.Server.put(value)
  end

  def put(%{__blunt_id: id}, key, value) when is_atom(key),
    do: put(id, key, value)

  def put(id, key, value) when is_atom(key) do
    id
    |> get_or_start_server()
    |> __MODULE__.Server.put(key, value)
  end

  def get(%{__blunt_id: id}),
    do: get(id)

  def get(id) do
    id
    |> get_or_start_server()
    |> __MODULE__.Server.get()
  end

  def get(%{__blunt_id: id}, key, default \\ nil) when is_atom(key) do
    id
    |> get()
    |> Map.get(key, default)
  end

  defp get_or_start_server(id) do
    spec = Supervisor.child_spec({__MODULE__.Server, id}, restart: :transient)

    case DynamicSupervisor.start_child(__MODULE__, spec) do
      {:ok, pid} -> pid
      {:ok, pid, _} -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end
end
