defmodule SWGOHCompanion do
  alias SWGOHCompanion.Hunters.{
    UpsertCharacterMods
  }

  defdelegate upsert_character_mods, to: UpsertCharacterMods
end
