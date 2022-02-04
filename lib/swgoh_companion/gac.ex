defmodule SWGOHCompanion.GAC do
  alias SWGOHCompanion.Hunters.GAC.{
    PrepareWeek,
    PrepareRound,
    UpsertEnemyTeams,
    SaveEnemyTeams
  }

  defdelegate prepare_week(week, gac_nr, week_nr, ally_codes), to: PrepareWeek
  defdelegate prepare_round(week, round_nr, ally_code), to: PrepareRound
  defdelegate upsert_enemy_teams(week, round_nr, teams), to: UpsertEnemyTeams
  defdelegate save_enemy_teams(week, round_nr, teams), to: SaveEnemyTeams
end
