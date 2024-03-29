defmodule SWGOHCompanion.Hunters.Common do
  alias SWGOHCompanion.SDK
  alias SWGOHCompanion.SDK.Models.Character
  alias SWGOHCompanion.Repo
  import Ecto.Query

  @data_folder "data"

  defmodule Team do
    @derive Jason.Encoder
    defstruct [
      :name,
      :leader_acronym,
      :power_sum,
      :max_speed,
      :zeta_sum,
      :omicron_sum,
      :characters
    ]
  end

  @team_acronyms %{
    "geos" => ["gba", "sf", "gso", "gsp", "ptl"],
    "cls" => ["cls", "chewie", "t&c", "c3po", "han"],
    "phoenix" => ["hs", "eb", "kj", "zeb", "chopper", "sw"],
    "phx" => ["hs", "eb", "kj", "zeb", "chopper", "sw"],
    "phxt" => ["hs", "eb", "kj", "zeb", "chopper"],
    "mm + rebel fighters" => [
      "mm",
      "cara",
      "bd",
      "hrsc",
      "wa",
      "srp",
      "bm",
      "hrso",
      "kk",
      "lc",
      "k2so",
      "ca",
      "ci",
      "je",
      "bistan",
      "br",
      "pao"
    ],
    "nightsisters" => ["mt", "od", "nz", "ns", "av", "talia", "ni"],
    "nst" => ["mt", "od", "nz", "ns", "av"],
    "bad batch" => ["hunter", "wrecker", "tech", "echo", "omega"],
    "first order" => ["kru", "kr", "hux", "sitht", "fox", "fotp", "foo", "fos", "fosftp", "cp"],
    "sith trio" => ["traya", "sion", "dn"],
    "separatists" => ["gg", "ng", "b1", "b2", "ig100", "cd", "jango", "ddk"],
    "sith empire" => ["dr", "bsf", "malak", "hk47", "set", "sm", "sa"],
    "bounty hunters" => [
      "bossk",
      "boba",
      "jango",
      "fs",
      "dengar",
      "mando",
      "greef",
      "zw",
      "ig-88",
      "cb",
      "greedo"
    ],
    "plug & play" => ["wampa", "en", "wt", "gat", "hoda", "bo", "armorer", "c3po", "r2d2"],
    "imperial troopers" => [
      "gv",
      "ap",
      "darkt",
      "ranget",
      "mg",
      "deatht",
      "cs",
      "snowt",
      "shoret"
    ],
    "ewoks" => ["cc", "ee", "es", "teebo", "logray", "wicket", "paploo"],
    "ewokt" => ["cc", "ee", "logray", "wicket", "paploo"],
    "galactic legends" => ["slkr", "jml", "rey", "see", "lv", "jmk"],
    "resistance" => [
      "jtr",
      "vshs",
      "vsc",
      "finn",
      "rs",
      "pd",
      "rp",
      "bb8",
      "rt",
      "rhf",
      "rhp",
      "ah",
      "rose"
    ],
    "sith" => [
      "dv",
      "ep",
      "traya",
      "sion",
      "dn",
      "cd",
      "ds",
      "dm",
      "bsf",
      "dt",
      "set",
      "sm",
      "so",
      "sa",
      "dm",
      "dr"
    ],
    "501st" => ["gas", "rex", "fives", "ctecho", "arct"],
    "stct" => ["st", "rex", "fives", "ctecho", "arct"],
    "or" => ["co", "candy", "juhani", "zaal", "mv"],
    "se" => ["dr", "bsf", "malak", "hk47", "set"],
    "jawas" => ["cn", "jawa", "dathcha", "js", "jawae"]
  }

  def form_teams_and_separate_rest_of_roster(roster) do
    teams =
      get_gac_enemy_roster()
      |> Enum.map(fn
        team when is_binary(team) -> {team, @team_acronyms[String.downcase(team)]}
        team when is_list(team) -> team
      end)
      |> Enum.map(fn
        {name, team} when is_list(team) -> {name, SDK.Acronyms.expand_acronyms(team)}
        team when is_list(team) -> {nil, SDK.Acronyms.expand_acronyms(team)}
      end)
      |> Enum.map(fn {name, team} -> {name, interpret_team(roster, team)} end)
      |> Enum.map(&build_team/1)
      |> Enum.uniq_by(fn %Team{characters: characters} ->
        characters
        |> Enum.map(& &1.name)
        |> MapSet.new()
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

  defp interpret_team(roster, team) do
    team
    |> Enum.map(fn {acronym, character_name} ->
      character =
        Enum.find(
          roster,
          &(String.downcase(character_name) == String.downcase(&1.name))
        )

      if character != nil do
        {acronym, character}
      else
        {acronym, Character.empty(character_name)}
      end
    end)
    |> Enum.with_index()
    |> Enum.sort_by(fn {{_acronym, %{power: power}}, idx} -> {idx != 0, -power} end)
    |> Enum.map(fn {value, _idx} -> value end)
  end

  def fetch_roster(week, round_nr) do
    roster =
      from(
        round in Repo.GACRound,
        where: round.week == ^week and round.round == ^round_nr,
        join: rr in Repo.GACRoundRoster,
        on: round.id == rr.gac_round_id,
        join: roster in Repo.GACRoster,
        on: rr.gac_roster_id == roster.id,
        where: roster.ally_code != ^SDK.current_user_ally_code(),
        select: roster.characters
      )
      |> Repo.one!()

    roster
    |> Enum.map(&Morphix.atomorphiform!/1)
    |> Enum.map(&Character.new/1)
  end

  def write_roster!(out_path, data) do
    out_path =
      @data_folder
      |> Path.join(out_path)
      |> Path.join("roster.json")

    File.mkdir_p!(Path.dirname(out_path))
    File.write!(out_path, data)
  end

  def write_teams!(out_path, data) do
    out_path =
      @data_folder
      |> Path.join(out_path)
      |> Path.join("teams.json")

    File.mkdir_p!(Path.dirname(out_path))
    File.write!(out_path, data)
  end

  defp build_team({name, characters}) do
    {leader_acronym, _} = hd(characters)

    name =
      if name != nil do
        name
      else
        "Team #{String.upcase(leader_acronym)}"
      end

    characters = Enum.map(characters, &elem(&1, 1))
    characters_with_power = Enum.filter(characters, &(&1.power > 5000))

    if characters_with_power != [] do
      power_sum =
        characters_with_power
        |> Enum.map(& &1.power)
        |> Enum.sort_by(&(-&1))
        |> Enum.take(5)
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
        name: name,
        leader_acronym: leader_acronym,
        power_sum: power_sum,
        max_speed: max_speed,
        zeta_sum: zeta_sum,
        omicron_sum: omicron_sum,
        characters: characters
      }
    else
      %Team{
        name: name,
        leader_acronym: leader_acronym,
        power_sum: 0,
        max_speed: 0,
        zeta_sum: 0,
        omicron_sum: 0,
        characters: characters
      }
    end
  end

  defp get_gac_enemy_roster do
    "gac_enemy_roster"
    |> File.read!()
    |> String.split("\n")
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(&String.split(&1, ","))
  end
end
