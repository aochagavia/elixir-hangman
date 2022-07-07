defmodule Server.GameStateTest do
  use ExUnit.Case, async: true
  doctest Server.Game.State

  alias Server.Game.State

  test "creates new" do
    state = State.with_word("something")

    assert state.word == "something"
    assert state.guesses == []
    assert state.failure_count == 0
  end

  test "update with existing char returns good guess and tracks it" do
    state = State.with_word("something")

    {result, new_state} = State.update(state, ?s)
    assert result == {:good_guess, [0]}
    assert new_state.word == state.word
    assert new_state.failure_count == state.failure_count
    assert new_state.guesses == 's'
  end

  test "update with non-existing char returns wrong guess and tracks it" do
    state = State.with_word("something")

    {result, new_state} = State.update(state, ?y)
    assert result == :wrong_guess
    assert new_state.word == state.word
    assert new_state.failure_count == state.failure_count + 1
    assert new_state.guesses == 'y'
  end

  test "update with non-existing char, already guessed, returns existing_guess and unchanged state" do
    {:wrong_guess, state} = State.update(State.with_word("something"), ?y)

    {result, new_state} = State.update(state, ?y)
    assert result == :existing_guess
    assert new_state == state
  end

  test "game outcome after creation is unknown" do
    state = State.with_word("something")

    assert State.game_outcome(state) == :unknown
  end

  test "game outcome after one correct guess is unknown" do
    state = State.with_word("something")

    assert State.game_outcome(state) == :unknown
  end

  test "game outcome after guessing everything is successful" do
    state = State.with_word("something")

    final_state =
      List.foldl(String.to_charlist("something"), state, fn char, state ->
        elem(State.update(state, char), 1)
      end)

    assert State.game_outcome(final_state) == :player_wins
  end
end
