defmodule SWGOHCompanion do
  alias SWGOHCompanion.Hunters.{
    SaveGacEnemyRoster,
    UpsertCharacterMods,
    UpsertGears,
    UpsertGacEnemyTeams,
    SaveGacEnemyTeams,
    PrepareGacWeek,
    PrepareRound
  }

  defdelegate upsert_character_mods, to: UpsertCharacterMods
  defdelegate upsert_gears, to: UpsertGears
  defdelegate prepare_gac_week(week, gac_nr, week_nr, ally_codes), to: PrepareGacWeek
  defdelegate prepare_round(week, round_nr, ally_code), to: PrepareRound
  defdelegate save_gac_enemy_roster(ally_code, out_path), to: SaveGacEnemyRoster
  defdelegate upsert_gac_enemy_teams(week, round_nr, teams), to: UpsertGacEnemyTeams
  defdelegate save_gac_enemy_teams(round_path, teams), to: SaveGacEnemyTeams
end
