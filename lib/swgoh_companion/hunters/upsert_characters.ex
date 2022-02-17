defmodule SWGOHCompanion.Hunters.UpsertCharacters do
  @sheet_name "Characters"
  @starting_row 2
  @starting_column "A"

  @character_name_mappings %{
    "Obi-Wan Kenobi" => "Obi-Wan Kenobi (Old Ben)",
    "Fives" => "CT-5555 \"Fives\"",
    "Rex" => "CT-7567 \"Rex\"",
    "\"Echo\"" => "CT-21-0408 \"Echo\"",
    "Chirrut Imwe" => "Chirrut Îmwe",
    "Cody" => "CC-2224 \"Cody\"",
    "Mara Jade" => "Mara Jade, The Emperor's Hand",
    "SLKR" => "Supreme Leader Kylo Ren",
    "B1" => "B1 Battle Droid",
    "B2" => "B2 Super Battle Droid",
    "IG-86" => "IG-86 Sentinel Droid"
  }
  @potential_roles [
    "Support",
    "Attacker",
    "Tank",
    "Healer"
  ]
  @rejected_categories ["Leader", "Unaligned Force User", "Fleet Commander"]

  use SWGOHCompanion.SDK, spreadsheet: true

  def upsert_characters do
    roster =
      SDK.get_player_roster().characters
      |> Enum.into(
        %{},
        fn %Character{
             name: name,
             power: power,
             stats: stats,
             rarity: rarity,
             gear: %Gear{
               level: gear_level
             },
             relic_tier: relic_tier,
             leader_ability: leader_ability,
             non_leader_abilities: non_leader_abilities,
             omega_abilities: omega_abilities,
             total_omega_abilities: total_omega_abilities,
             zeta_abilities: zeta_abilities,
             total_zeta_abilities: total_zeta_abilities
           } ->
          zetas_learnt = Enum.count(zeta_abilities)
          total_zetas = Enum.count(total_zeta_abilities)
          omegas_learnt = Enum.count(omega_abilities)
          total_omegas = Enum.count(total_omega_abilities)

          minimum_ability_level =
            non_leader_abilities
            |> Enum.map(&(&1.tier - &1.max_tier))
            |> Enum.min(fn -> nil end)

          leader_ability_level = if leader_ability, do: leader_ability.tier

          {
            name,
            %{
              power: power,
              rarity: rarity,
              minimum_ability_level: minimum_ability_level,
              leader_ability_level: leader_ability_level,
              gear_level: gear_level,
              relic_tier: relic_tier,
              stats: stats,
              zetas_learnt: zetas_learnt,
              total_zetas: total_zetas,
              omegas_learnt: omegas_learnt,
              total_omegas: total_omegas
            }
          }
        end
      )

    character_data =
      SDK.get_all_characters()
      |> Enum.into(%{}, fn character ->
        role =
          character
          |> Map.get("categories")
          |> Enum.filter(fn category -> category in @potential_roles end)
          |> hd

        factions =
          character
          |> Map.get("categories")
          |> Enum.reject(fn category -> category in [role | @rejected_categories] end)

        {
          Map.get(character, "name"),
          %{
            factions: factions,
            role: role
          }
        }
      end)

    full_data =
      Enum.reduce([character_data, roster], %{}, fn map, acc ->
        SDK.recursive_merge(acc, map)
      end)

    ["A2:A"]
    |> read_spreadsheet_rows()
    |> Enum.map(fn
      [character] ->
        name = Map.get(@character_name_mappings, character, character)
        data = Map.get(full_data, name, %{})
        Map.put(data, :name, character)
    end)
    |> Enum.sort_by(& -&1.power)
    |> write_rows()
  end

  def to_spreadsheet_rows(data) do
    data
    |> Enum.map(fn %{
      name: name,
      power: power,
      rarity: rarity,
      minimum_ability_level: minimum_ability_level,
      leader_ability_level: leader_ability_level,
      gear_level: gear_level,
      relic_tier: relic_tier,
      stats: %Stats{
        speed: speed
      },
      zetas_learnt: zetas_learnt,
      total_zetas: total_zetas,
      omegas_learnt: omegas_learnt,
      total_omegas: total_omegas,
      factions: factions,
      role: role
    } ->
      factions =
        factions
        |> Enum.map(&String.replace(&1, " ", ""))
        |> Enum.join("\n")
      [
          name,
          power,
          factions,
          role,
          rarity,
          minimum_ability_level,
          gear_level,
          relic_tier,
          if(leader_ability_level != nil, do: Integer.to_string(leader_ability_level), else: ""),
          zetas_learnt,
          total_zetas,
          omegas_learnt,
          total_omegas,
          speed
      ]
    end)
  end
end
