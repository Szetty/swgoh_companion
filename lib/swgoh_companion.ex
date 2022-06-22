defmodule SWGOHCompanion do
  alias SWGOHCompanion.Hunters.{
    UpsertCharacterMods,
    UpsertGears,
    UpsertCharacters,
    UpsertMissingGearCount,
    UpsertGeos
  }

  defdelegate upsert_character_mods, to: UpsertCharacterMods
  defdelegate upsert_gears, to: UpsertGears
  defdelegate upsert_characters, to: UpsertCharacters
  defdelegate upsert_missing_gear_count, to: UpsertMissingGearCount
  defdelegate upsert_geos(ally_code, starting_row), to: UpsertGeos
end
