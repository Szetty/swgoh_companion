defmodule SWGOHCompanion do
  alias SWGOHCompanion.Hunters.{
    SaveGacEnemyRoster,
    UpsertCharacterMods,
    UpsertGears,
    UpsertGacEnemyRoster
  }

  defdelegate save_gac_enemy_roster(ally_code, teams, out_path), to: SaveGacEnemyRoster
  defdelegate upsert_character_mods, to: UpsertCharacterMods
  defdelegate upsert_gears, to: UpsertGears
  defdelegate upsert_gac_enemy_roster(ally_code, params), to: UpsertGacEnemyRoster
end
