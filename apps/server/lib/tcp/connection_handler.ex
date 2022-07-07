defmodule Server.Tcp.ConnectionHandler do
  use GenServer

  def start(opts) do
    GenServer.start(__MODULE__, opts)
  end

  @impl true
  def init(opts) do
    socket = opts[:socket]

    word = opts[:word_provider].provide_word()
    game = Server.Game.State.with_word(word)

    # Our custom protocol specifies that the server sends the selected word's length right after
    # the connection has been established
    :ok = :gen_tcp.send(socket, <<String.length(game.word)>>)

    {:ok, %{socket: socket, game: game}}
  end

  @impl true
  def handle_info({:tcp, _socket, <<guess>>}, %{socket: socket, game: game} = state) do
    {guess_result, new_game} = Server.Game.State.update(game, guess)
    game_outcome = Server.Game.State.game_outcome(new_game)

    :ok = :gen_tcp.send(socket, Server.Encoding.encode_guess_result(guess_result, game_outcome))

    {:noreply, state |> Map.put(:game, new_game)}
  end

  def handle_info(msg, state) do
    {:stop, {:unknown_message, msg}, state}
  end
end
