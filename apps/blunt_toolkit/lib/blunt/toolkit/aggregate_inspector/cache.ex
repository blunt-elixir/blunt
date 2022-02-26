defmodule Blunt.Toolkit.AggregateInspector.Cache do
  @cache_file "_build/cqrs_toolkit_aggregate_inspector_cache"

  use GenServer

  def start_link do
    state = read_all()
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(state), do: {:ok, state}

  def get(config, key) do
    case GenServer.call(__MODULE__, {:get, key}) do
      nil -> config
      value -> Map.put(config, key, to_string(value) |> String.trim_leading("Elixir."))
    end
  end

  def put(key, value), do: GenServer.call(__MODULE__, {:write, key, value})

  def handle_call({:get, key}, _from, state) do
    {:reply, Map.get(state, key, ""), state}
  end

  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:write, key, value}, _from, state) do
    state = Map.put(state, key, value)

    _result = File.write!(@cache_file, inspect(state))

    {:reply, value, state}
  end

  defp read_all do
    unless File.exists?(@cache_file) do
      %{}
    else
      {values, _} =
        @cache_file
        |> File.read!()
        |> Code.eval_string()

      values
    end
  end
end
