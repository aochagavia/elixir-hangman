defmodule Server.Encoding do
  @spec encode_guess_result(Server.Game.State.guess_result(), Server.Game.State.game_outcome()) ::
          [integer()]
  def encode_guess_result(result, outcome) do
    case outcome do
      :player_wins ->
        [0]

      :player_loses ->
        [1]

      :unknown ->
        case result do
          {:good_guess, indexes} ->
            [2, Enum.count(indexes)] ++ indexes

          :wrong_guess ->
            [3]

          :existing_guess ->
            [4]
        end
    end
  end
end
