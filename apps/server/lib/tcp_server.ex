defmodule TcpServer do
  def run() do
    # `:binary` = receives data as binaries (instead of lists)
    {:ok, socket} = :gen_tcp.listen(8080, [:binary])
    accept(socket)
  end

  def accept(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    {:ok, pid} = Task.start(fn -> TcpServer.handle_client(client) end)

    # Necessary so the newly created process receives messages
    :gen_tcp.controlling_process(client, pid)

    accept(socket)
  end

  def handle_client(client) do
    game = Game.new()

    # Our custom protocol specifies that the server sends the selected word's length right after
    # the connection has been established
    state = Game.state(game)
    :ok = :gen_tcp.send(client, <<String.length(state.word)>>)

    game_loop(client, game)
  end

  defp game_loop(client, game) do
    guess = get_next_guess()
    {result, outcome} = handle_guess(game, guess)
    :ok = :gen_tcp.send(client, Encoding.encode_guess_result(result, outcome))

    game_loop(client, game)
  end

  defp get_next_guess() do
    receive do
      {:tcp, _socket, <<guess>>} -> guess
      unknown -> IO.puts("Unknown message received, closing connection: #{inspect(unknown)}")
    end
  end

  @spec handle_guess(pid, integer) :: {Game.State.guess_result(), Game.Stae.game_outcome()}
  defp handle_guess(game, guess) do
    guess_result = Game.guess(game, guess)
    new_state = Game.state(game)
    game_outcome = Game.State.game_outcome(new_state)

    {guess_result, game_outcome}
  end
end
