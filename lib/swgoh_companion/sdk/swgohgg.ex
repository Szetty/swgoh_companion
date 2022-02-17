defmodule SWGOHCompanion.SDK.SWGOHGG do
  alias SWGOHCompanion.SDK
  alias SDK.HTTP
  alias SDK.Models.{PlayerData, Character, Stats, Gear, Ability}

  @player "473362279"
  @percentage_threshold 10

  @characters_url "https://swgoh.gg/api/characters"
  @player_url "https://swgoh.gg/api/player"

  @speed_stat "5"

  def get_all_characters() do
    IO.puts("Fetching characters")

    HTTP.get_json(@characters_url)
  end

  def get_player(player \\ @player) do
    IO.puts("Fetching player for #{player}")

    @player_url
    |> Path.join("#{player}")
    |> HTTP.get_json()
    |> decode_player_response()
  end

  def get_player_roster(player \\ @player) do
    IO.puts("Fetching roster for #{player}")

    @player_url
    |> Path.join(player)
    |> HTTP.get_json()
    |> Map.get("units")
    |> decode_player_roster_response()
  end

  defp decode_player_response(%{
         "data" => %{
           "name" => player_name,
           "guild_name" => guild_name
         },
         "units" => units
       }) do
    units
    |> decode_player_roster_response()
    |> Map.put(:name, player_name)
    |> Map.put(:guild_name, guild_name)
  end

  defp decode_player_roster_response(units) do
    characters =
      units
      |> Enum.filter(&(get_in(&1, ["data", "combat_type"]) == 1))
      |> Enum.map(&decode_character/1)

    %PlayerData{
      characters: characters
    }
  end

  defp decode_character(%{
         "data" => %{
           "base_id" => id,
           "name" => name,
           "power" => power,
           "stats" => %{
             @speed_stat => speed
           },
           "rarity" => rarity,
           "gear" => equipped_gear,
           "gear_level" => gear_level,
           "relic_tier" => relic_tier,
           "ability_data" => ability_data,
           "zeta_abilities" => zeta_abilities,
           "omicron_abilities" => omicron_abilities
         }
       }) do
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

    %Character{
      id: id,
      name: name,
      power: power,
      stats: %Stats{
        speed: speed
      },
      rarity: rarity,
      gear: %Gear{
        level: gear_level,
        count: gear_count
      },
      # Quick fix for swgoh.gg bug where relic tiers are always bigger with 2
      relic_tier: max(relic_tier - 2, 0),
      # relic_tier: relic_tier,
      leader_ability: leader_ability,
      non_leader_abilities: non_leader_abilities,
      omega_abilities: omega_abilities,
      total_omega_abilities: total_omega_abilities,
      zeta_abilities: zeta_abilities,
      total_zeta_abilities: total_zeta_abilities,
      omicron_abilities: omicron_abilities
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
end
