defmodule GameStateTest do
  use ExUnit.Case
  doctest Game.State

  test "creates new" do
    state = Game.State.with_word("something")

    assert state.word == "something"
    assert state.guesses == []
    assert state.failure_count == 0
  end

  test "update with existing char returns good guess and tracks it" do
    state = Game.State.with_word("something")

    {result, new_state} = Game.State.update(state, ?s)
    assert result == {:good_guess, [0]}
    assert new_state.word == state.word
    assert new_state.failure_count == state.failure_count
    assert new_state.guesses == 's'
  end

  test "update with non-existing char returns wrong guess and tracks it" do
    state = Game.State.with_word("something")

    {result, new_state} = Game.State.update(state, ?y)
    assert result == :wrong_guess
    assert new_state.word == state.word
    assert new_state.failure_count == state.failure_count + 1
    assert new_state.guesses == 'y'
  end

  test "update with non-existing char, already guessed, returns existing_guess and unchanged state" do
    {:wrong_guess, state} = Game.State.update(Game.State.with_word("something"), ?y)

    {result, new_state} = Game.State.update(state, ?y)
    assert result == :existing_guess
    assert new_state == state
  end

  test "game outcome after creation is unknown" do
    state = Game.State.with_word("something")

    assert Game.State.game_outcome(state) == :unknown
  end

  test "game outcome after one correct guess is unknown" do
    state = Game.State.with_word("something")

    assert Game.State.game_outcome(state) == :unknown
  end

  test "game outcome after guessing everything is successful" do
    state = Game.State.with_word("something")
    final_state = List.foldl(String.to_charlist("something"), state, fn (char, state) -> elem(Game.State.update(state, char), 1) end)

    assert Game.State.game_outcome(final_state) == :player_wins
  end
end
