defmodule ServerState do
  defstruct word: "", guesses: [], failure_count: 0, game_outcome: :unknown

  @type t :: %ServerState{word: String.t(), guesses: [integer], failure_count: integer}
  @type guess_result :: {:good_guess, [integer]} | :wrong_guess | :existing_guess
  @type game_outcome :: :player_wins | :player_loses | :unknown

  @spec with_word(String.t()) :: ServerState.t()
  def with_word(word) do
    %ServerState{word: word}
  end

  @spec with_random_word :: ServerState.t()
  def with_random_word() do
    # I promise this is random (see https://xkcd.com/221/)
    %ServerState{word: "platipus"}
  end

  @spec update(ServerState.t(), integer) :: {ServerState.guess_result(), ServerState.t()}
  def update(state, guess) do
    cond do
      Enum.member?(state.guesses, guess) ->
        {:existing_guess, state}
      String.contains?(state.word, <<guess>>) ->
        {_, indexes} = List.foldl(String.to_charlist(state.word), {0, []}, fn (char, {index, matching_indexes}) ->
          {index + 1, if char == guess do [index] ++ matching_indexes else matching_indexes end} end)
        {{:good_guess, indexes}, %{state | guesses: [guess] ++ state.guesses }}
      true ->
        {:wrong_guess, %{state | guesses: [guess] ++ state.guesses, failure_count: state.failure_count + 1}}
    end
  end

  @spec game_outcome(ServerState.t()) :: ServerState.game_outcome()
  def game_outcome(state) do
    cond do
      state.failure_count == 5 -> :player_loses
      Enum.all?(String.to_charlist(state.word), fn char -> Enum.member?(state.guesses, char) end) -> :player_wins
      true -> :unknown
    end
  end
end
