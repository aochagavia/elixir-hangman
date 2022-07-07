defmodule Server.Game.State do
  defstruct word: "", guesses: [], failure_count: 0

  @type t :: %Server.Game.State{word: String.t(), guesses: [integer], failure_count: integer}
  @type guess_result :: {:good_guess, [integer]} | :wrong_guess | :existing_guess
  @type game_outcome :: :player_wins | :player_loses | :unknown

  @spec with_word(String.t()) :: Server.Game.State.t()
  def with_word(word) do
    %Server.Game.State{word: word}
  end

  @spec update(Server.Game.State.t(), integer) ::
          {Server.Game.State.guess_result(), Server.Game.State.t()}
  def update(state, guess) do
    cond do
      Enum.member?(state.guesses, guess) ->
        {:existing_guess, state}

      String.contains?(state.word, <<guess>>) ->
        {_, indexes} =
          List.foldl(String.to_charlist(state.word), {0, []}, fn char,
                                                                 {index, matching_indexes} ->
            {index + 1,
             if char == guess do
               [index | matching_indexes]
             else
               matching_indexes
             end}
          end)

        {{:good_guess, indexes}, %{state | guesses: [guess | state.guesses]}}

      true ->
        {:wrong_guess,
         %{state | guesses: [guess | state.guesses], failure_count: state.failure_count + 1}}
    end
  end

  @spec game_outcome(Server.Game.State.t()) :: Server.Game.State.game_outcome()
  def game_outcome(state) do
    cond do
      state.failure_count == 5 ->
        :player_loses

      Enum.all?(String.to_charlist(state.word), fn char -> Enum.member?(state.guesses, char) end) ->
        :player_wins

      true ->
        :unknown
    end
  end
end
