defmodule Server.TcpIntegrationTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, monitor} = Server.Tcp.ConnectionMonitor.start_link([], name: Server.TcpIntegrationTest)

    {:ok, server} =
      Server.Tcp.ConnectionListener.start_link(
        port: 8080,
        connection_monitor: monitor,
        word_provider: Server.Support.MockWordProvider
      )

    %{
      server: server,
      port: 8080,
      connection_monitor: monitor
    }
  end

  test "server sends word length upon connecting", context do
    socket = connect(context.port)
    {:ok, <<word_length>>} = :gen_tcp.recv(socket, 1)

    assert String.length(Server.Support.MockWordProvider.provide_word()) == word_length
  end

  test "server keeps track of client connections", context do
    assert 0 == GenServer.call(context.connection_monitor, :player_count)

    socket1 = connect(context.port)

    with_retry(fn ->
      assert 1 == GenServer.call(context.connection_monitor, :player_count)
    end)

    socket2 = connect(context.port)

    with_retry(fn ->
      assert 2 == GenServer.call(context.connection_monitor, :player_count)
    end)

    :ok = :gen_tcp.shutdown(socket2, :read_write)

    with_retry(fn ->
      assert 1 == GenServer.call(context.connection_monitor, :player_count)
    end)

    :ok = :gen_tcp.shutdown(socket1, :read_write)

    with_retry(fn ->
      assert 0 == GenServer.call(context.connection_monitor, :player_count)
    end)
  end

  test "server allows new connection after existing connection crashed", context do
    socket = connect(context.port)
    :ok = :gen_tcp.shutdown(socket, :read_write)

    # Works
    connect(context.port)
  end

  defp connect(port) do
    {:ok, socket} = :gen_tcp.connect('localhost', port, [:binary, packet: 0, active: false])
    socket
  end

  defp with_retry(fun, timeout \\ 100)

  defp with_retry(fun, 0) do
    fun.()
  end

  defp with_retry(fun, timeout) do
    try do
      fun.()
    rescue
      ExUnit.AssertionError ->
        Process.sleep(10)
        with_retry(fun, max(0, timeout - 10))
    end
  end
end
