defmodule Blunt.Message.State.Server do
  @timeout :timer.minutes(1)
  use GenServer, restart: :transient

  def start_link(id) do
    name = {:global, inspect(__MODULE__) <> "/" <> id}
    GenServer.start_link(__MODULE__, %{id: id}, name: name)
  end

  def get(pid), do: GenServer.call(pid, :get)

  def put(pid, key, value),
    do: GenServer.call(pid, {:put, key, value})

  def put(pid, value) when is_map(value),
    do: GenServer.call(pid, {:put, value})

  @impl true
  def init(state), do: {:ok, state}

  @impl true
  def handle_call(:get, _from, state),
    do: {:reply, state, state, @timeout}

  def handle_call({:put, value}, _from, state) do
    new_state = Map.merge(state, value)
    {:reply, new_state, new_state, @timeout}
  end

  def handle_call({:put, key, value}, _from, state) do
    new_state = Map.put(state, key, value)
    {:reply, new_state, new_state, @timeout}
  end
end
