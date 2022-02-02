defmodule SWGOHCompanion.Hunters.SaveGacEnemyTeams do
  use SWGOHCompanion.SDK
  alias SWGOHCompanion.Hunters.Common

  def save_gac_enemy_teams("", _), do: raise("Round is required")

  def save_gac_enemy_teams(round_path, teams) do
    round_path
    |> Common.fetch_roster()
    |> Common.form_teams_and_separate_rest_of_roster(teams)
    |> write_to_json(round_path)
  end

  defp write_to_json({teams, roster}, round_path) do
    %{
      "rest_of_roster" => roster,
      "teams" => teams
    }
    |> Jason.encode!(pretty: true)
    |> then(&Common.write_teams!(round_path, &1))
  end
end
