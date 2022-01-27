defmodule SWGOHCompanion.Hunters.Common do
  alias SWGOHCompanion.SDK
  alias SWGOHCompanion.SDK.Models.Character

  defmodule Team do
    @derive Jason.Encoder
    defstruct [
      :name,
      :power_avg,
      :max_speed,
      :zeta_sum,
      :omicron_sum,
      :characters
    ]
  end

  @default_teams [
    ["gas", "st", "rex", "fives", "ctecho", "arct"],
    ["gba", "sf", "gso", "gsp", "ptl"],
    ["ep", "mj", "dv"],
    ["jkr", "gmy", "bs", "jb", "jkl", "gk"],
    ["gv", "ap", "darkt", "ranget", "mg", "deatht", "cs"],
    ["cls", "chewie", "t&c", "c3po", "han"],
    ["bossk", "boba", "jango", "fs", "dengar", "mando", "greef", "zw", "ig-88"],
    ["padme", "jka", "at", "gk"],
    ["bando", "ig11", "kuiil"],
    ["p&p", "wampa", "en", "wt", "gat", "hoda"],
    ["cc", "ee", "es", "teebo", "logray", "wicket", "paploo"],
    ["co", "candy", "zaal", "mv", "juhani"]
  ]

  @team_acronyms %{
    "geos" => ["gba", "sf", "gso", "gsp", "ptl"],
    "cls" => ["cls", "chewie", "t&c", "c3po", "han"]
  }

  def form_teams_and_separate_rest_of_roster(roster, :default) do
    form_teams_and_separate_rest_of_roster(roster, @default_teams)
  end

  def form_teams_and_separate_rest_of_roster(roster, teams) do
    teams =
      teams
      |> Enum.map(fn
        team when is_binary(team) -> @team_acronyms[team]
        team when is_list(team) -> team
      end)
      |> Enum.map(&SDK.Acronyms.expand_acronyms(&1))
      |> Enum.map(&interpret_team(roster, &1))
      |> Enum.map(fn characters ->
        {leader_acronym, _} = hd(characters)
        characters = Enum.map(characters, &elem(&1, 1))
        characters_with_power = Enum.filter(characters, & &1.power > 5000)
        power_avg =
          characters_with_power
          |> Enum.map(& &1.power)
          |> Enum.sum()
          |> Kernel./(Enum.count(characters_with_power))
          |> Float.round()
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
          power_avg: power_avg,
          max_speed: max_speed,
          zeta_sum: zeta_sum,
          omicron_sum: omicron_sum,
          characters: characters
        }
      end)
      |> Enum.sort_by(&(-&1.power_avg))

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

  defp interpret_team(roster, team) do
    team
    |> Enum.map(
      fn {acronym, character_name} ->
        character = Enum.find(
          roster,
          &(String.downcase(character_name) == String.downcase(&1.name))
        )
        if character != nil do
          {acronym, character}
        else
          {acronym, Character.empty(character_name)}
        end
      end
    )
    |> Enum.with_index()
    |> Enum.sort_by(fn {{_acronym, %{power: power}}, idx} -> {idx != 0, -power} end)
    |> Enum.map(fn {value, _idx} -> value end)
  end

  def fetch_roster(round_path) do
    %{"roster" => roster} =
      round_path
      |> Path.join("roster.json")
      |> File.read!()
      |> Jason.decode!()

    roster
    |> Enum.map(&Morphix.atomorphiform!/1)
    |> Enum.map(&Character.new/1)
  end
end
