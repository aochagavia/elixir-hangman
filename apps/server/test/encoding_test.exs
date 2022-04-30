defmodule EncodingTest do
  use ExUnit.Case
  doctest Encoding

  test "encode good guess result includes indexes" do
    encoded = Encoding.encode_guess_result({:good_guess, [1, 2, 5]}, :unknown)

    assert encoded == [2, 3, 1, 2, 5]
  end
end
