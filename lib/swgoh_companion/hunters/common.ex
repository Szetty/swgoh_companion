defmodule SWGOHCompanion.Hunters.Common do
  alias SWGOHCompanion.SDK

  defmodule Team do
    @derive Jason.Encoder
    defstruct [
      :name,
      :power_sum,
      :max_speed,
      :zeta_sum,
      :omicron_sum,
      :characters
    ]
  end

  def form_teams_and_separate_rest_of_roster(roster, teams) do
    teams =
      teams
      |> Enum.map(&SDK.Acronyms.expand_acronyms(&1))
      |> Enum.map(fn team ->
        Enum.map(
          team,
          fn {acronym, character_name} ->
            character = Enum.find(
              roster,
              &(String.downcase(character_name) == String.downcase(&1.name))
            )
            if character != nil do
              {acronym, character}
            else
              raise "Could not find character #{character_name}"
            end
          end
        )
      end)
      |> Enum.map(fn characters ->
        {leader_acronym, _} = hd(characters)
        characters = Enum.map(characters, &elem(&1, 1))
        power_sum =
          characters
          |> Enum.map(& &1.power)
          |> Enum.sum()
        max_speed =
          characters
          |> Enum.map(& &1.stats.speed)
          |> Enum.max()
        zeta_sum =
          characters
          |> Enum.map(&Enum.count(&1.zeta_abilities))
          |> Enum.sum()
        omicron_sum =
          characters
          |> Enum.map(&Enum.count(&1.omicron_abilities))
          |> Enum.sum()

        %Team{
          name: "Team #{String.upcase(leader_acronym)}",
          power_sum: power_sum,
          max_speed: max_speed,
          zeta_sum: zeta_sum,
          omicron_sum: omicron_sum,
          characters: characters
        }
      end)
      |> Enum.sort_by(&(-&1.power_sum))

    characters_in_teams =
      teams
      |> Enum.map(& &1.characters)
      |> List.flatten()
      |> Enum.map(& &1.name)

    rest_of_roster =
      roster
      |> Enum.filter(&(&1.name not in characters_in_teams))
      |> Enum.sort_by(&(-&1.power))

    {teams, rest_of_roster}
  end

end
