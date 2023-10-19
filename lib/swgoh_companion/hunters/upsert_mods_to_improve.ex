defmodule SWGOHCompanion.Hunters.UpsertModsToImprove do
  @sheet_name "Mods to improve"
  @starting_row 2
  @starting_column "A"

  use SWGOHCompanion.SDK, spreadsheet: true

  alias SWGOHCompanion.SDK.Acronyms

  @champion_priority [
    "SLKR",
    "DR",
    "MG",
    "JKR",
    "DV",
    "Echo",
    "AP",
    "Malgus",
    "Bossk",
    "NG",
    "BB8",
    "MJ",
    "GAT",
    "Rex",
    "FOTP",
    "ZW",
    "CLS",
    "Padme",
    "GMY",
    "BSF",
    "Tech",
    "ST",
    "R2D2",
    "GV",
    "Armorer",
    "Hoda",
    "JTR",
    "Mando",
    "Sion",
    "Greef",
    "Traya",
    "DN",
    "Hunter",
    "CD",
    "QGJ",
    "IV",
    "EE",
    "BS",
    "DT",
    "CS",
    "FOO",
    "Hux",
    "Han",
    "WT"
  ]

  @secondary_stats %{
    "SLKR" => [:offense],
    "DR" => [:offense],
    "DV" => [:potency, :crit_chance],
    "Echo" => [:potency],
    "Malgus" => [:health],
    "Bossk" => [:protection],
    "NG" => [:potency],
    "BB8" => [:crit_chance],
    "MJ" => [:potency],
    "CLS" => [:tenacity],
    "Padme" => [:health],
    "Tech" => [:potency],
    "R2D2" => [:potency],
    "JTR" => [:crit_chance],
    "Mando" => [:crit_chance],
    "CD" => [:potency],
    "QGJ" => [:offense],
    "Han" => [:crit_chance],
    "CS" => [:potency]
  }

  def mods_to_improve do
    character_name_by_id =
      SDK.get_all_characters()
      |> Enum.into(%{}, fn %{"base_id" => id, "name" => name} ->
        {id, name}
      end)

    %PlayerData{characters: characters} = SDK.get_all_player_data()

    characters_by_name =
      characters
      |> Enum.into(%{}, &{character_name_by_id[&1.id], &1})

    @champion_priority
    |> Acronyms.expand_acronyms()
    |> Enum.map(fn {acronym, name} ->
      IO.inspect(acronym)

      %Character{
        stats: %Stats{speed: speed},
        mod_stats: %Stats{speed: speed_from_mods},
        mods: mods
      } = characters_by_name[name]

      sets =
        mods
        |> Enum.map(& &1.set_stat_name)
        |> Enum.frequencies()
        |> Enum.filter(fn {_, count} -> count >= 2 end)
        |> Enum.sort_by(fn {_, count} -> -count end)
        |> Enum.map(fn {stat, _} -> stat end)

      mods =
        mods
        |> Enum.sort_by(& &1.slot)
        |> Enum.map(fn %{
                         primary_stat_name: primary_stat_name,
                         rarity: rarity,
                         tier: tier,
                         level: level,
                         secondary_stats: secondary_stats,
                         slot: slot
                       } ->
          interested_secondary_stats =
            secondary_stats
            |> Map.from_struct()
            |> Enum.filter(fn {stat_name, _} ->
              is_secondary_stat_needed?(Map.get(@secondary_stats, acronym, []), stat_name)
            end)

          %{
            slot: slot,
            primary_stat_name: primary_stat_name,
            rarity: rarity,
            tier: tier,
            level: level,
            secondary_stats: interested_secondary_stats
          }
        end)

      %{
        name: name,
        sets: sets,
        mods: mods,
        speed_from_mods: speed_from_mods,
        speed: speed
      }
    end)
    |> write_rows()
  end

  def to_spreadsheet_rows(data) do
    data
    |> Enum.flat_map(fn %{
                          name: name,
                          sets: sets,
                          mods: mods,
                          speed_from_mods: speed_from_mods,
                          speed: speed
                        } ->
      {set1, set2, set3} =
        case sets do
          [set1] -> {set1, "", ""}
          [set1, set2] -> {set1, set2, ""}
          [set1, set2, set3] -> {set1, set2, set3}
        end

      mods_basic_info =
        mods
        |> Enum.flat_map(&[&1.primary_stat_name, &1.rarity, &1.tier])

      stat_indices =
        mods
        |> Enum.flat_map(& &1.secondary_stats)
        |> Enum.map(fn {stat_name, _} -> stat_name end)
        |> Enum.uniq()
        |> Enum.sort_by(fn stat_name ->
          if stat_name == :speed, do: 0, else: 1
        end)
        |> Enum.with_index()
        |> Map.new()

      secondary_stats =
        mods
        |> Enum.flat_map(fn %{secondary_stats: secondary_stats, slot: slot} ->
          secondary_stats
          |> Enum.map(fn {stat_name, %{value: value, rolls: rolls}} ->
            {slot, stat_name, value, rolls}
          end)
        end)
        |> Enum.sort_by(fn {slot, stat_name, _, _} -> {stat_indices[stat_name], slot} end)
        |> Enum.map(fn {_, stat_name, value, rolls} ->
          [translate_stat_name(stat_name), value, rolls]
        end)
        |> Enum.chunk_every(6)
        |> Enum.with_index()
        |> Enum.map(fn {row, index} ->
          row = List.flatten(row)

          case index do
            0 ->
              ["", "", "", set2 | row]

            1 ->
              ["", "", "", set3 | row]

            _ ->
              ["", "", "", "" | row]
          end
        end)

      [[name, speed, speed_from_mods, set1 | mods_basic_info] | secondary_stats] ++ [[""]]
    end)
  end

  defp is_secondary_stat_needed?(_, :speed), do: true

  defp is_secondary_stat_needed?(interested_secondary_stats, stat_name) do
    interested_secondary_stats
    |> Enum.any?(fn secondary_stat_name ->
      case secondary_stat_name do
        :offense ->
          stat_name in [:offense, :offense_percent]

        :health ->
          stat_name in [:health, :health_percent]

        :protection ->
          stat_name in [:protection, :protection_percent]

        ^stat_name ->
          true

        _ ->
          false
      end
    end)
  end

  defp translate_stat_name(stat_name) do
    case stat_name do
      :speed ->
        "Speed"

      :offense ->
        "Offense"

      :offense_percent ->
        "Offense%"

      :potency ->
        "Potency"

      :tenacity ->
        "Tenacity"

      :health ->
        "Health"

      :health_percent ->
        "Health%"

      :protection ->
        "Protection"

      :protection_percent ->
        "Protection%"

      :crit_chance ->
        "Critical Chance"
    end
  end
end
