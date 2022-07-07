defmodule Server.Game.WordProvider do
  @callback provide_word() :: String.t()
end
