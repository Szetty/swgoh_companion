defmodule S.GAC do

  alias SWGOHCompanion.Repo
  alias Repo.{GACRound, GACRoundRoster, GACRoster, GACTeam}
  import Ecto.Query
  alias SWGOHCompanion.SDK

  def get_enemy_team(week, round_nr, leader_acronym) do
    from(
      round in GACRound,
      where: round.week == ^week and round.round == ^round_nr,
      join: round_roster in GACRoundRoster,
      on: round.id == round_roster.gac_round_id,
      join: roster in GACRoster,
      on: round_roster.gac_roster_id == roster.id,
      where: roster.ally_code != ^SDK.current_user_ally_code(),
      join: team in GACTeam,
      on: roster.id == team.gac_roster_id,
      where: ilike(team.leader_acronym, ^"%#{leader_acronym}%"),
      select: team
    )
    |> Repo.one!()
    |> IO.inspect()
  end

  def transform_teams_to_input do
    ~s"""
    qgj,owk,bs,jb,mw
    padme,at,jka,gmy,gk
    co,candy,zaal,mw,t3m4
    jtr,bb8,reys,ah,vshs
    jml,jkr,gas,jkl,hoda
    bossk,boba,jango,mando,cb
    """
    |> String.split("\n")
    |> Enum.reject(& &1 == "")
    |> Enum.map(&String.split(&1, ","))
    |> Enum.map(&Enum.map(&1, fn s -> "\"#{String.trim(s)}\"" end))
    |> Enum.map(fn
      [a] -> a
      l -> "[" <> Enum.join(l, ",") <> "]"
    end)
    |> Enum.join(",")
    |> IO.puts
  end

end
