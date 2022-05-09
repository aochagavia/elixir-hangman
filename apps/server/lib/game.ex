defmodule Game do
  @spec new :: pid
  def new() do
    {:ok, pid} = Agent.start_link(fn -> Game.State.with_word("platipus") end)
    pid
  end

  @spec guess(pid, integer) :: Game.State.guess_result()
  def guess(pid, char) do
    Agent.get_and_update(pid, fn state -> Game.State.update(state, char) end)
  end

  @spec state(pid) :: Game.State.t()
  def state(pid) do
    Agent.get(pid, fn state -> state end)
  end
end
