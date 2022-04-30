defmodule ClientStateTest do
  use ExUnit.Case
  doctest ClientState

  test "starts with underscores" do
    assert ClientState.with_length(5).hidden_word == "_____"
  end

  test "updates state based on indexes" do
    state = ClientState.with_length(5)

    first_update = ClientState.update(state, ?a, [0, 3])
    assert first_update.hidden_word == "a__a_"

    second_update = ClientState.update(first_update, ?b, [2])
    assert second_update.hidden_word == "a_ba_"
  end

  test "updates state for last guess" do
    state = ClientState.with_length(5)
    first_update = ClientState.update(state, ?a, [0, 3])
    last_update = ClientState.update_last_guess(first_update, ?c)

    assert last_update.hidden_word == "accac"
  end
end
