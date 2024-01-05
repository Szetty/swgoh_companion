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
end
