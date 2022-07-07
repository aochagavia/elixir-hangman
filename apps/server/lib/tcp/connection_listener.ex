defmodule Server.Tcp.ConnectionListener do
  @moduledoc """
  A GenServer with the only goal of accepting new connections. Upon a new
  connection, it will spawn a dedicated GenServer to handle the game for
  that player
  """

  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(opts) do
    state = %{
      socket: nil,
      port: opts[:port] || 8080,
      word_provider: opts[:word_provider] || Server.Game.HardcodedWordProvider,
      connection_monitor: opts[:connection_monitor] || Server.Tcp.ConnectionMonitor
    }

    {:ok, state, {:continue, :ok}}
  end

  @impl true
  def handle_continue(:ok, state) do
    {:ok, socket} = :gen_tcp.listen(state.port, [:binary])

    # Start accepting after continue
    GenServer.cast(__MODULE__, :accept)

    {
      :noreply,
      state
      |> Map.put(:socket, socket)
    }
  end

  def handle_continue(:accept_next, state) do
    GenServer.cast(__MODULE__, :accept)
    {:noreply, state}
  end

  @impl true
  def handle_cast(:accept, state) do
    # TODO: handle the case in which accept fails
    {:ok, client} = :gen_tcp.accept(state.socket)

    # TODO: will the listener crash if the client fails to start? I think so...
    {:ok, pid} =
      Server.Tcp.ConnectionHandler.start(socket: client, word_provider: state.word_provider)

    :gen_tcp.controlling_process(client, pid)

    GenServer.cast(state.connection_monitor, {:monitor, pid})

    {
      :noreply,
      state,
      {:continue, :accept_next}
    }
  end
end
