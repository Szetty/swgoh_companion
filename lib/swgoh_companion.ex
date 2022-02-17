defmodule SWGOHCompanion do
  alias SWGOHCompanion.Hunters.{
    UpsertCharacterMods,
    UpsertGears,
    UpsertCharacters
  }

  defdelegate upsert_character_mods, to: UpsertCharacterMods
  defdelegate upsert_gears, to: UpsertGears
  defdelegate upsert_characters, to: UpsertCharacters
end
