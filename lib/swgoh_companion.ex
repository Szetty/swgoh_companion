defmodule SWGOHCompanion do
  alias SWGOHCompanion.Hunters.{
    SaveGacEnemyRoster,
    UpsertCharacterMods,
    UpsertGears,
    UpsertGacEnemyTeams,
    SaveGacEnemyTeams
  }

  defdelegate upsert_character_mods, to: UpsertCharacterMods
  defdelegate upsert_gears, to: UpsertGears
  defdelegate save_gac_enemy_roster(ally_code, out_path), to: SaveGacEnemyRoster
  defdelegate upsert_gac_enemy_teams(round_path, teams), to: UpsertGacEnemyTeams
  defdelegate save_gac_enemy_teams(round_path, teams), to: SaveGacEnemyTeams
end
