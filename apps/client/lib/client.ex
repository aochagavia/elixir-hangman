defmodule Client do
  def run do
    {:ok, socket} = :gen_tcp.connect('localhost', 8080, [:binary, packet: 0, active: false])

    # The server always sends the word length as the first message
    {:ok, <<word_length>>} = :gen_tcp.recv(socket, 1)
    state = ClientState.with_length(word_length)
    play(socket, state)
  end

  @spec play(any(), ClientState.t()) :: any()
  defp play(socket, state) do
    IO.puts("Current word: #{inspect state.hidden_word}")
    <<guess>> = String.trim(IO.gets("Guess the next letter: "))

    :ok = :gen_tcp.send(socket, <<guess>>)
    {:ok, <<code>>} = :gen_tcp.recv(socket, 1)

    case code do
      0 ->
        final_state = ClientState.update_last_guess(state, guess)
        IO.puts("You win! The word was #{inspect final_state.hidden_word}")
      1 -> IO.puts("You lose!")
      2 ->
        {:ok, <<occurrences>>} = :gen_tcp.recv(socket, 1)

        # Generator ranges are inclusive!
        guessed_indexes = for _ <- 1..occurrences do
          {:ok, <<index>>} = :gen_tcp.recv(socket, 1)
          index
        end

        IO.puts("Good guess! Now for the next one...")
        play(socket, ClientState.update(state, guess, guessed_indexes))
      3 ->
        IO.puts("Wrong guess...")
        play(socket, state)
      4 ->
        IO.puts("You already guessed that letter")
        play(socket, state)
    end
  end
end
