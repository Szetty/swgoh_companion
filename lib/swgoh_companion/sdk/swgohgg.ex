defmodule SWGOHCompanion.SDK.SWGOHGG do
  alias SWGOHCompanion.SDK
  alias SDK.HTTP
  alias SDK.Models.{PlayerData, Character, Stats, Gear, Ability, GAC}

  @player "473362279"
  @percentage_threshold 10

  @base_url "https://swgoh.gg"
  @api_base_url "http://api.swgoh.gg"

  @characters_url Path.join(@api_base_url, "/characters")
  @player_url Path.join(@api_base_url, "/player")

  @stat_ids_and_multipliers %{
    health: {"1", 1},
    protection: {"28", 1},
    speed: {"5", 1},
    crit_damage: {"16", 100},
    potency: {"17", 100},
    tenacity: {"18", 100},
    physical_damage: {"6", 1},
    crit_chance: {"14", 1},
    armor: {"8", 1}
  }

  def get_all_characters() do
    IO.puts("Fetching characters")

    HTTP.get_json(@characters_url)
  end

  def get_player(player \\ @player) do
    IO.puts("Fetching player for #{player}")

    @player_url
    |> Path.join("#{player}")
    |> HTTP.get_json()
    |> decode_player_response(player)
  end

  def get_player_roster(player \\ @player) do
    IO.puts("Fetching roster for #{player}")

    @player_url
    |> Path.join(player)
    |> HTTP.get_json()
    |> Map.get("units")
    |> decode_player_roster_response(player)
  end

  defp decode_player_response(%{
         "data" => %{
           "name" => player_name,
           "guild_name" => guild_name,
           "last_updated" => last_updated
         },
         "units" => units
       }, ally_code) do
    {:ok, last_updated, 0} =
      last_updated
      |> Kernel.<>("Z")
      |> DateTime.from_iso8601()

    units
    |> decode_player_roster_response(ally_code)
    |> Map.put(:name, player_name)
    |> Map.put(:guild_name, guild_name)
    |> Map.put(:last_updated, last_updated)
  end

  defp decode_player_roster_response(units, ally_code) do
    characters =
      units
      |> Enum.filter(&(get_in(&1, ["data", "combat_type"]) == 1))
      |> Enum.map(&decode_character(&1, ally_code))

    %PlayerData{
      characters: characters
    }
  end

  defp decode_character(%{
         "data" => %{
           "base_id" => id,
           "name" => name,
           "power" => power,
           "stats" => stats,
           "rarity" => rarity,
           "gear" => equipped_gear,
           "gear_level" => gear_level,
           "relic_tier" => relic_tier,
           "ability_data" => ability_data,
           "zeta_abilities" => zeta_abilities,
           "omicron_abilities" => omicron_abilities,
           "url" => character_path
         }
       }, ally_code) do
    stats =
      @stat_ids_and_multipliers
      |> Enum.map(fn {stat_name, {stat_id, multiplier}} ->
        stat_value = stats[stat_id]
        {stat_name, stat_value * multiplier}
      end)
      |> Stats.new()

    gear_count = Enum.count(equipped_gear, &Map.get(&1, "is_obtained"))

    abilities =
      ability_data
      |> Enum.map(&decode_ability(ability_data, &1["id"]))

    leader_ability = Enum.find(abilities, &(&1.type == "leader"))

    non_leader_abilities = Enum.reject(abilities, &(&1.type == "leader"))

    omega_abilities =
      ability_data
      |> Enum.filter(fn
        %{"is_omega" => true, "ability_tier" => level, "tier_max" => level} -> true
        _ -> false
      end)
      |> Enum.map(&decode_ability(ability_data, &1["id"]))

    total_omega_abilities =
      ability_data
      |> Enum.filter(fn
        %{"is_omega" => true} -> true
        _ -> false
      end)
      |> Enum.map(&decode_ability(ability_data, &1["id"]))

    zeta_abilities = Enum.map(zeta_abilities, &decode_ability(ability_data, &1))

    total_zeta_abilities =
      ability_data
      |> Enum.filter(fn
        %{"is_zeta" => true} -> true
        _ -> false
      end)
      |> Enum.map(&decode_ability(ability_data, &1["id"]))

    omicron_abilities = Enum.map(omicron_abilities, &decode_ability(ability_data, &1))

    # Quick fix for swgoh.gg bug where relic tiers are always bigger with 2
    relic_tier = max(relic_tier - 2, 0)
    if ally_code == "473362279" && name == "Darth Vader" do
      if relic_tier != 9, do: raise("Incorrect relic tier #{relic_tier}")
    end

    %Character{
      id: id,
      name: name,
      power: power,
      stats: stats,
      rarity: rarity,
      gear: %Gear{
        level: gear_level,
        count: gear_count
      },
      relic_tier: relic_tier,
      leader_ability: leader_ability,
      non_leader_abilities: non_leader_abilities,
      omega_abilities: omega_abilities,
      total_omega_abilities: total_omega_abilities,
      zeta_abilities: zeta_abilities,
      total_zeta_abilities: total_zeta_abilities,
      omicron_abilities: omicron_abilities,
      url: Path.join(@base_url, character_path)
    }
  end

  defp decode_ability(ability_data, ability_id) do
    %{
      "name" => name,
      "ability_tier" => tier,
      "tier_max" => max_tier
    } = Enum.find(ability_data, &(Map.get(&1, "id") == ability_id))

    scan_result = Regex.scan(~r/^(.+)skill_.+(\d{2})$/, ability_id)

    {type, order} =
      if scan_result != [] do
        [[_, type, order]] = scan_result
        {order, ""} = Integer.parse(order)
        {type, order}
      else
        [[_, type]] = Regex.scan(~r/^(.+)skill_.+$/, ability_id)
        {type, nil}
      end

    %Ability{
      name: name,
      type: type,
      order: order,
      tier: tier,
      max_tier: max_tier
    }
  end

  @spec get_most_popular_mods([any()]) :: stream :: Enum.t()
  def get_most_popular_mods(characters \\ get_all_characters()) do
    characters
    |> Enum.map(fn %{"name" => name, "url" => url} -> {name, url} end)
    |> Stream.map(fn {name, character_url_path} ->
      {:ok, document} =
        character_url_path
        |> get_mod_recommendation()
        |> Floki.parse_document()

      [mod_sets | mod_slots] =
        Floki.find(document, "div.content-container-primary > ul > li.media")

      mod_sets =
        mod_sets
        |> Floki.find("tbody > tr")
        |> Enum.map(fn tr ->
          [sets, _count, percentage] = Floki.find(tr, "td")

          sets =
            sets
            |> Floki.find("div[data-title]")
            |> Enum.map(fn div ->
              div
              |> Floki.attribute("div", "data-title")
              |> hd()
              |> String.replace(~r/Set Bonus: \d+% /, "")
            end)

          percentage =
            percentage
            |> Floki.text()
            |> String.trim_trailing("%")
            |> String.to_integer()

          {sets, percentage}
        end)

      mod_slots =
        mod_slots
        |> Enum.map(fn mod_slot_html ->
          mod_slot_html
          |> Floki.find("tbody > tr")
          |> Enum.map(fn tr ->
            [name, _count, percentage] =
              tr
              |> Floki.find("td")
              |> Enum.map(&Floki.text/1)

            percentage =
              percentage
              |> String.trim_trailing("%")
              |> String.to_integer()

            {name, percentage}
          end)
        end)

      {name, mod_sets, mod_slots}
    end)
    |> Stream.map(fn {name, mod_sets, mod_slots} ->
      relevant_mod_sets =
        Enum.filter(mod_sets, fn {_, percentage} -> percentage > @percentage_threshold end)

      [relevant_receivers, relevant_data_buses, relevant_holo_arrays, relevant_multiplexers] =
        Enum.map(mod_slots, fn primary_mods ->
          Enum.filter(primary_mods, fn {_, percentage} -> percentage > @percentage_threshold end)
        end)

      {
        name,
        relevant_mod_sets,
        relevant_receivers,
        relevant_data_buses,
        relevant_holo_arrays,
        relevant_multiplexers
      }
    end)
  end

  def get_mod_recommendation(base_url) do
    base_url
    |> Path.join("/data/mods?filter_type=guilds_100_raid")
    |> HTTP.get_http_body()
  end

  def get_current_gac_bracket(ally_code) do
    @api_base_url
    |> Path.join("/player/#{ally_code}/gac-bracket/")
    |> HTTP.get_json()
    |> decode_gac_bracket_response()
  end

  defp decode_gac_bracket_response(%{
    "data" => %{
      "start_time" => start_time,
      "season_number" => gac_nr,
      "bracket_players" => players
    }
  }) do
    {:ok, start_time, 0} =
      start_time
      |> Kernel.<>("Z")
      |> DateTime.from_iso8601()

    week = Calendar.strftime(start_time, "%Y_%m_%d")

    ally_codes = Enum.map(players, & &1["ally_code"])

    %GAC.Bracket{
      week: week,
      gac_nr: gac_nr,
      start_time: start_time,
      ally_codes: ally_codes
    }
  end
end
