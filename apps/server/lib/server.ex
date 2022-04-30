defmodule Server do
  # Note that the server is so basic it only handles a single client, and closes afterwards
  def accept() do
    # `:binary` = receives data as binaries (instead of lists)
    # `active: false` = blocks on `:gen_tcp.recv/2` until data is available
    {:ok, socket} = :gen_tcp.listen(8080, [:binary, active: false])
    {:ok, client} = :gen_tcp.accept(socket)
    state = ServerState.with_random_word()

    # Our custom protocol specifies that the server sends the selected word's length right after
    # the connection has been established
    :ok = :gen_tcp.send(client, <<String.length(state.word)>>)

    process_next_guess(client, state)
  end

  defp process_next_guess(socket, state) do
    {:ok, <<guess>>} = :gen_tcp.recv(socket, 1)

    {result, new_state} = ServerState.update(state, guess)
    outcome = ServerState.game_outcome(new_state)

    :ok = :gen_tcp.send(socket, Encoding.encode_guess_result(result, outcome))

    process_next_guess(socket, new_state)
  end
end
