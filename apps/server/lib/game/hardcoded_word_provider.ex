defmodule Server.Game.HardcodedWordProvider do
  @behaviour Server.Game.WordProvider

  @spec provide_word :: String.t()
  def provide_word() do
    ["platipus", "tree", "pumpkin", "elixir"]
    |> Enum.random()
  end
end
