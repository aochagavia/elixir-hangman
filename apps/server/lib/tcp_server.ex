defmodule TcpServer do
  def run() do
    # `:binary` = receives data as binaries (instead of lists)
    # `active: false` = blocks on `:gen_tcp.recv/2` until data is available
    {:ok, socket} = :gen_tcp.listen(8080, [:binary, active: false])
    accept(socket)
  end

  def accept(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    spawn(TcpServer, :handle_client, [client])
    accept(socket)
  end

  def handle_client(client) do
    game = Game.new()

    # Our custom protocol specifies that the server sends the selected word's length right after
    # the connection has been established
    state = :sys.get_state(game)
    :ok = :gen_tcp.send(client, <<String.length(state.word)>>)

    process_next_guess(client, game)
  end

  defp process_next_guess(socket, game) do
    {:ok, <<guess>>} = :gen_tcp.recv(socket, 1)

    result = Game.guess(game, guess)
    new_state = :sys.get_state(game)
    outcome = Game.State.game_outcome(new_state)

    :ok = :gen_tcp.send(socket, Encoding.encode_guess_result(result, outcome))

    process_next_guess(socket, game)
  end
end
