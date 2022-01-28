defmodule SWGOHCompanion.Hunters.SaveGacEnemyRoster do
  use SWGOHCompanion.SDK
  alias SWGOHCompanion.Hunters.Common

  def save_gac_enemy_roster("", _), do: raise "ALLY_CODE is required"
  def save_gac_enemy_roster(_, ""), do: raise "OUT_PATH is required"

  def save_gac_enemy_roster(ally_code, out_path) when is_binary(ally_code) and is_binary(out_path) do
    (SDK.get_player_roster(ally_code)).characters
    |> write_to_json(out_path, ally_code)
  end

  defp write_to_json(roster, out_path, ally_code) do
    %{
      "ally_code" => ally_code,
      "roster" => roster
    }
    |> Jason.encode!(pretty: true)
    |> then(&Common.write_roster!(out_path, &1))
  end

end
