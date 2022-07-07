defmodule Server.EncodingTest do
  use ExUnit.Case, async: true
  doctest Server.Encoding

  test "encode good guess result includes indexes" do
    encoded = Server.Encoding.encode_guess_result({:good_guess, [1, 2, 5]}, :unknown)

    assert encoded == [2, 3, 1, 2, 5]
  end
end
