defmodule SWGOHCompanion.Hunters.GAC.SaveEnemyTeams do
  use SWGOHCompanion.SDK
  alias SWGOHCompanion.Hunters.Common
  alias Common.Team
  alias SWGOHCompanion.Repo
  alias Ecto.Multi
  import Ecto.Query

  def save_enemy_teams(week, round_nr, teams) do
    Common.fetch_roster(week, round_nr)
    |> Common.form_teams_and_separate_rest_of_roster(teams)
    |> write_to_db(week, round_nr)
  end

  defp write_to_db({teams, _roster}, week, round_nr) do
    round =
      from(
        round in Repo.GACRound,
        where: round.week == ^week and round.round == ^round_nr,
        preload: [:gac_rosters]
      )
      |> Repo.one!()

    [roster] =
      round.gac_rosters
      |> Enum.reject(&(&1.ally_code != SDK.current_user_ally_code()))

    teams
    |> Enum.reduce(Multi.new(), fn %Team{} = team, multi ->
      insert_team_operation_name = :"insert_gac_team_#{team.name}"

      attrs = %{
        leader_acronym: team.leader_acronym,
        characters: team.characters,
        stats: %{
          power_avg: team.power_avg,
          max_speed: team.max_speed,
          zeta_sum: team.zeta_sum,
          omicron_sum: team.omicron_sum
        }
      }

      multi
      |> Multi.insert(
        insert_team_operation_name,
        roster
        |> Ecto.build_assoc(:gac_teams)
        |> Repo.GACTeam.changeset(attrs)
      )
      |> Multi.insert(
        :"insert_gac_round_team_#{team.name}",
        fn %{^insert_team_operation_name => team} ->
          Repo.GACRoundTeam.changeset(round, team, %{})
        end
      )
    end)
    |> Repo.transaction()
  end
end
