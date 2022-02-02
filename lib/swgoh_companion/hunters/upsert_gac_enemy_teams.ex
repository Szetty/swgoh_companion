defmodule SWGOHCompanion.Hunters.UpsertGacEnemyTeams do
  @sheet_name "GAC Enemy Roster"
  @starting_row 2
  @starting_column "A"

  use SWGOHCompanion.SDK, spreadsheet: true
  alias SDK.Models.{Character, Stats, Gear, Ability}
  alias SWGOHCompanion.Hunters.Common
  alias Common.Team

  def upsert_gac_enemy_teams(week, round_nr, teams) do
    Common.fetch_roster(week, round_nr)
    |> Common.form_teams_and_separate_rest_of_roster(teams)
    |> write_rows()
  end

  def to_spreadsheet_rows({teams, rest_of_roster}) do
    teams =
      teams
      |> Enum.map(fn %Team{
                       name: name,
                       power_avg: power_avg,
                       max_speed: max_speed,
                       zeta_sum: zeta_sum,
                       omicron_sum: omicron_sum,
                       characters: characters
                     } ->
        [[name, power_avg, "", "", max_speed, zeta_sum, "", omicron_sum, ""]] ++
          Enum.map(characters, &stringify_character/1) ++
          [[]]
      end)
      |> Enum.concat()

    rest_of_roster =
      rest_of_roster
      |> Enum.map(&stringify_character/1)

    teams ++ rest_of_roster
  end

  defp stringify_character(%Character{
         name: name,
         power: power,
         stats: %Stats{
           speed: speed
         },
         gear: %Gear{
           level: level,
           count: count
         },
         relic_tier: relic_tier,
         zeta_abilities: zeta_abilities,
         omicron_abilities: omicron_abilities
       }) do
    zeta_count = Enum.count(zeta_abilities)
    zeta_abilities = Enum.map(zeta_abilities, &stringify_ability/1) |> Enum.join(",")
    omicron_count = Enum.count(omicron_abilities)
    omicron_abilities = Enum.map(omicron_abilities, &stringify_ability/1) |> Enum.join(",")

    [
      name,
      power,
      "#{level}-#{count}",
      relic_tier,
      speed,
      zeta_count,
      zeta_abilities,
      omicron_count,
      omicron_abilities
    ]
  end

  defp stringify_ability(%Ability{type: type, order: order}) do
    if order != nil do
      "#{type}-#{order}"
    else
      type
    end
  end
end
