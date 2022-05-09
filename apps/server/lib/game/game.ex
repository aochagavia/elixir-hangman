defmodule Game do
  @spec new :: pid
  def new() do
    {:ok, pid} = GenServer.start_link(Game.Server, nil)
    pid
  end

  @spec guess(pid, integer) :: Game.State.guess_result()
  def guess(pid, char) do
    GenServer.call(pid, {:guess, char})
  end

  @spec state(pid) :: Game.State.t()
  def state(pid) do
    :sys.get_state(pid)
  end
end
