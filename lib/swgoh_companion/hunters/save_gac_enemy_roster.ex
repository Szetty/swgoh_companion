defmodule SWGOHCompanion.Hunters.SaveGacEnemyRoster do
  use SWGOHCompanion.SDK
  alias SWGOHCompanion.Hunters.Common
  alias Common.Team

  def save_gac_enemy_roster(nil, _, _), do: raise "ALLY_CODE is required"
  def save_gac_enemy_roster(_, _, nil), do: raise "OUT_PATH is required"

  def save_gac_enemy_roster(ally_code, teams, out_path) do
    (SDK.get_player_roster(ally_code)).characters
    |> Common.form_teams_and_separate_rest_of_roster(teams)
    |> write_to_json(out_path, ally_code)
  end

  defp write_to_json({teams, rest_of_roster}, out_path, ally_code) do
    %{
      "ally_code" => ally_code,
      "teams" => teams,
      "rest_of_roster" => rest_of_roster
    }
    |> Jason.encode!()
    |> then(fn data ->
      File.write!(out_path, data)
    end)
  end

end
