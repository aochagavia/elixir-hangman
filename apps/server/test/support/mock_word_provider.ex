defmodule Server.Support.MockWordProvider do
  @behaviour Game.WordProvider

  def provide_word() do
    "someword"
  end
end
