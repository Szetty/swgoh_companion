defmodule SWGOHCompanion.Hunters.UpsertGeos do
  @sheet_name "Guild WAT Geos"
  @starting_column "A"

  use SWGOHCompanion.SDK, spreadsheet: true
  alias SWGOHCompanion.SDK.Acronyms

  @geo_names ["gba", "sf", "gsp", "gso", "ptl"]

  @important_stats_with_limits %{
    "gba" => %{
      speed: 260
    },
    "sf" => %{
      hp_and_prot: 125000,
      armor: 50
    },
    "gsp" => %{
      physical_damage: 3500,
      crit_chance: 75,
      speed: 200
    },
    "gso" => %{
      crit_chance: 85,
      physical_damage: 3500
    },
    "ptl" => %{
      speed: 250,
      potency: 80
    }
  }

  def upsert_geos(ally_code, starting_row) do
    %PlayerData{name: name, characters: characters} = SDK.get_player(ally_code)

    characters_by_name = Enum.into(characters, %{}, &{&1.name, &1})

    geos =
      @geo_names
      |> Acronyms.expand_acronyms()
      |> Enum.map(fn {geo_acronym, name} ->
        stat_limits = @important_stats_with_limits[geo_acronym]
        %Character{stats: %Stats{
          speed: speed,
          health: health,
          protection: protection,
          physical_damage: physical_damage,
          crit_chance: crit_chance,
          armor: armor,
          potency: potency
        }} = characters_by_name[name]

        hp_and_prot = health + protection

        %{
          name: name,
          speed: speed,
          speed_limit: stat_limits[:speed],
          hp_and_prot: hp_and_prot,
          hp_and_prot_limit: stat_limits[:hp_and_prot],
          armor: armor,
          armor_limit: stat_limits[:armor],
          physical_damage: physical_damage,
          physical_damage_limit: stat_limits[:physical_damage],
          crit_chance: crit_chance,
          crit_chance_limit: stat_limits[:crit_chance],
          potency: potency,
          potency_limit: stat_limits[:potency]
        }
      end)

    %{name: name, geos: geos}
    |> write_rows(starting_row)
  end

  def to_spreadsheet_rows(%{name: name, geos: geos}) do
    [[name, "Speed", "Speed Limit", "HP+Prot", "HP+Prot Limit", "Armor", "Armor Limit", "Physical Damage", "Physical Damage Limit", "Crit Chance", "Crit Chance Limit", "Potency", "Potency Limit"]]
    ++ (
      geos
      |> Enum.map(fn geo ->
        [
          geo[:name],
          geo[:speed],
          geo[:speed_limit],
          geo[:hp_and_prot],
          geo[:hp_and_prot_limit],
          geo[:armor] |> Float.round(2),
          geo[:armor_limit],
          geo[:physical_damage],
          geo[:physical_damage_limit],
          geo[:crit_chance] |> Float.round(2),
          geo[:crit_chance_limit],
          geo[:potency] |> Float.round(2),
          geo[:potency_limit]
        ]
      end)
    )
  end

end
