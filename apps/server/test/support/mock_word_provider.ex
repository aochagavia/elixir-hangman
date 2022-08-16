defmodule Server.Support.MockWordProvider do
  @behaviour Server.Game.WordProvider

  def provide_word() do
    "someword"
  end
end
