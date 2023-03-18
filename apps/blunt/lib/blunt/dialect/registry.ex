defmodule Blunt.Dialect.Registry do
  @moduledoc false

  alias Blunt.Dialect
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def get_dialect! do
    :ets.first(__MODULE__)
  end

  def put_dialect(%Blunt.Dialect{} = dialect) do
    GenServer.call(__MODULE__, {:put_dialect, dialect})
  end

  def restore_dialect do
    GenServer.call(__MODULE__, :restore_dialect)
  end

  @impl true
  def init(:ok) do
    table = :ets.new(__MODULE__, [:named_table, read_concurrency: true])
    table = put_configured_dialect!(table)
    {:ok, table}
  end

  @impl true
  def handle_call({:put_dialect, dialect}, _from, table) do
    true = :ets.delete_all_objects(table)
    true = :ets.insert(table, {dialect})
    {:reply, :ok, table}
  end

  def handle_call(:restore_dialect, _from, table) do
    table = put_configured_dialect!(table)
    {:reply, :ok, table}
  end

  defp put_configured_dialect!(table) do
    dialect = Dialect.configured_dialect!()
    true = :ets.delete_all_objects(table)
    true = :ets.insert(table, {dialect})
    table
  end
end
