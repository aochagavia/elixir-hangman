defmodule ClientState do
  defstruct hidden_word: ""
  @type t :: %ClientState{hidden_word: String.t()}

  @spec with_length(non_neg_integer) :: ClientState.t()
  def with_length(length) do
    underscores = String.duplicate("_", length)
    %ClientState{hidden_word: underscores}
  end

  @spec update(ClientState.t(), integer(), [integer()]) :: ClientState.t()
  def update(state, guess, indexes) do
    chars = String.to_charlist(state.hidden_word)

    new_string =
      List.foldl(indexes, chars, fn index, updated_chars ->
        List.update_at(updated_chars, index, fn _ -> guess end)
      end)
      |> List.to_string()

    %{state | hidden_word: new_string}
  end

  @spec update_last_guess(ClientState.t(), integer()) :: ClientState.t()
  def update_last_guess(state, guess) do
    final_word = String.replace(state.hidden_word, "_", <<guess>>)
    %ClientState{hidden_word: final_word}
  end
end
