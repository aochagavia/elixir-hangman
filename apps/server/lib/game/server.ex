defmodule Game.Server do
  use GenServer

  @spec init(any) :: {:ok, Game.State.t()}
  def init(_) do
    {:ok, Game.State.with_word("platipus")}
  end

  def handle_call({:guess, char}, _from, %Game.State{} = state) do
    {result, updated_state} = Game.State.update(state, char)
    {:reply, result, updated_state}
  end
end
