defmodule SWGOHCompanion.Hunters.UpsertCharacterMods do
  @sheet_name "Mods"
  @starting_row 2
  @starting_column "A"

  use SWGOHCompanion.SDK, spreadsheet: true

  def upsert_character_mods do
    character_name_by_id =
      SDK.get_all_characters()
      |> Enum.into(%{}, fn %{"base_id" => id, "name" => name} ->
        {id, name}
      end)

    %PlayerData{characters: characters} = SDK.get_all_player_data()

    characters
    |> Enum.map(fn %Character{
                     id: id,
                     power: power,
                     stats: %Stats{speed: speed},
                     mod_stats: %Stats{speed: speed_from_mods},
                     mods: mods
                   } ->
      name = Map.fetch!(character_name_by_id, id)

      mods =
        mods
        |> Enum.into(%{}, fn %Mod{
                               tier: tier,
                               rarity: rarity,
                               level: level,
                               primary_stat_name: primary_stat_name,
                               primary_stats: %Stats{speed: speed_from_primary},
                               secondary_stats: %ModSecondaryStats{
                                 speed: %{value: speed_from_secondary}
                               },
                               set_stat_name: set_stat_name,
                               slot: slot
                             } ->
          {
            slot,
            %{
              tier: tier,
              rarity: rarity,
              level: level,
              primary_stat: primary_stat_name,
              set_stat: set_stat_name,
              speed: speed_from_primary + speed_from_secondary
            }
          }
        end)

      %{
        name: name,
        power: power,
        speed: speed,
        speed_from_mods: speed_from_mods,
        mods: mods
      }
    end)
    |> Enum.sort_by(fn %{power: power} -> -power end)
    |> write_rows()
  end

  @impl true
  def to_spreadsheet_rows(data) do
    data
    |> Enum.map(fn %{
                     name: name,
                     power: power,
                     speed: speed,
                     speed_from_mods: speed_from_mods,
                     mods: mods
                   } ->
      mods =
        2..7
        |> Enum.map(fn mod_slot ->
          mod = mods[mod_slot]

          if mod do
            %{
              tier: tier,
              rarity: rarity,
              level: level,
              primary_stat: primary_stat,
              set_stat: set_stat,
              speed: speed
            } = mod

            ["", "", "", speed, tier, rarity, level, primary_stat, set_stat]
          else
            ["", "", "", 0, "", "", "", "", ""]
          end
        end)

      [[name, power, speed, speed_from_mods]] ++ mods
    end)
    |> Enum.concat()
  end
end
