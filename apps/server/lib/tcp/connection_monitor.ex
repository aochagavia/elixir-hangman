defmodule Server.Tcp.ConnectionMonitor do
  use GenServer

  def start_link(init_args, opts \\ []) do
    name = opts[:name] || __MODULE__
    GenServer.start_link(__MODULE__, init_args, name: name)
  end

  @impl true
  def init(_) do
    {:ok, %{}}
  end

  @impl true
  def handle_call(:player_count, _from, state) do
    {:reply, map_size(state), state}
  end

  @impl true
  def handle_cast({:monitor, pid}, state) do
    ref = Process.monitor(pid)
    {:noreply, Map.put(state, ref, pid)}
  end

  @impl true
  def handle_info({:DOWN, ref, :process, _pid, _reason}, state) do
    {:noreply, Map.delete(state, ref)}
  end
end
