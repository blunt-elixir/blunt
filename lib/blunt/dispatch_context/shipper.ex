defmodule Blunt.DispatchContext.Shipper do
  @type context :: Blunt.DispatchContext.t()
  @callback ship(context()) :: :ok

  use GenServer

  def start_link(_opts) do
    shipper = Blunt.Config.context_shipper!()
    GenServer.start_link(__MODULE__, shipper, name: __MODULE__)
  end

  def ship(context),
    do: GenServer.cast(__MODULE__, {:ship, context})

  @impl true
  def init(state),
    do: {:ok, state}

  @impl true
  def handle_cast({:ship, _context}, nil),
    do: {:noreply, nil}

  @impl true
  def handle_cast({:ship, context}, shipper) do
    shipper.ship(context)
    {:noreply, shipper}
  end
end
