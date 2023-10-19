defmodule SWGOHCompanion.SDK.Hotutils do
  alias SWGOHCompanion.SDK
  alias SDK.HTTP
  alias SDK.Models.{PlayerData, Character, Mod, Stats, Gear, ModSecondaryStats}

  @url "https://hotutils.com/Production/account/data/all"
  @sessionID "4a9accbe-cb2e-40eb-84cd-0ca76b9ccd3e"
  @userID "898a36a3-948a-4a8a-9798-7a1552b042a8"

  def get_all_player_data() do
    @url
    |> HTTP.post!(
      Jason.encode!(%{
        "sessionId" => @sessionID
      }),
      headers: [
        {"content-type", "application/json"},
        {"APIUserId", @userID}
      ]
    )
    |> Map.get(:body)
    |> Jason.decode!()
    |> decode_response()
  end

  defp decode_response(%{"data" => %{"units" => %{"units" => units}}}) do
    characters =
      units
      |> Enum.filter(fn %{"combatType" => combatType} -> combatType == 1 end)
      |> Enum.map(&decode_character/1)

    %PlayerData{characters: characters}
  end

  defp decode_character(%{
         "baseId" => id,
         "power" => %{
           "total" => power
         },
         "stats" => stats,
         "mods" => mod_stats,
         "equippedMods" => mods,
         "gear" => %{
           "level" => gear_level,
           "count" => gear_count
         }
       }) do
    if id == "VADER" do
      IO.inspect(mods)
    end

    %Character{
      id: id,
      power: power,
      stats: decode_stats(stats),
      mod_stats: decode_mod_stats(mod_stats),
      mods: Enum.map(mods, &decode_mod/1),
      gear: %Gear{
        level: gear_level,
        count: gear_count
      }
    }
  end

  defp decode_stats(%{"speed" => speed}) do
    %Stats{speed: speed}
  end

  defp decode_mod_stats(%{"plusSpeed" => speed}) do
    %Stats{speed: speed}
  end

  defp decode_mod(%{
         "tier" => tier,
         "rarity" => rarity,
         "level" => level,
         "primary" => primary,
         "secondary" => secondary_stats,
         "set" => set,
         "slot" => slot
       }) do
    {primary_stat_name, primary_stats} = decode_primary_stats(primary)

    %Mod{
      tier: tier,
      rarity: rarity,
      level: level,
      primary_stat_name: primary_stat_name,
      primary_stats: primary_stats,
      set_stat_name: decode_set_stat_name(set),
      secondary_stats: decode_secondary_stats(secondary_stats),
      slot: slot,
      slot_name: to_slot_name(slot)
    }
  end

  defp decode_primary_stats(%{
         "statName" => primary_stat_name,
         "value" => primary_stat_value
       }) do
    speed = if primary_stat_name == "Speed", do: primary_stat_value, else: 0

    {primary_stat_name, %Stats{speed: speed}}
  end

  defp decode_set_stat_name(%{"icon" => set_icon_name}) do
    set_icon_name
    |> String.replace_leading("icon_buff_", "")
    |> String.replace_leading("icon_", "")
    |> String.replace_leading("attack", "offense")
    |> String.replace_leading("armor", "defense")
    |> String.replace_leading("accuracy", "potency")
    |> String.split("_")
    |> Enum.join(" ")
    |> String.capitalize()
  end

  defp decode_secondary_stats(secondary_stats) do
    secondary_stat_finder = fn stat_id ->
      %{"value" => value, "rolls" => rolls} =
        Enum.find(
          secondary_stats,
          %{"value" => 0, "rolls" => 0},
          fn
            %{"statId" => ^stat_id} -> true
            _ -> false
          end
        )

      %{value: value, rolls: rolls}
    end

    speed = secondary_stat_finder.(5)
    offense = secondary_stat_finder.(41)
    offense_percent = secondary_stat_finder.(48)
    potency = secondary_stat_finder.(17)
    tenacity = secondary_stat_finder.(18)
    health = secondary_stat_finder.(1)
    health_percent = secondary_stat_finder.(55)
    protection = secondary_stat_finder.(28)
    protection_percent = secondary_stat_finder.(56)
    crit_chance = secondary_stat_finder.(53)

    %ModSecondaryStats{
      speed: speed,
      offense: offense,
      offense_percent: offense_percent,
      potency: potency,
      tenacity: tenacity,
      health: health,
      health_percent: health_percent,
      protection: protection,
      protection_percent: protection_percent,
      crit_chance: crit_chance
    }
  end

  defp to_slot_name(slot) do
    case slot do
      2 -> "Square"
      3 -> "Arrow"
      4 -> "Diamond"
      5 -> "Triangle"
      6 -> "Circle"
      7 -> "Cross"
    end
  end
end
