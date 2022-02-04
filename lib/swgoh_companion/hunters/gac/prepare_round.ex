defmodule SWGOHCompanion.Hunters.GAC.PrepareRound do
  use SWGOHCompanion.SDK
  alias SWGOHCompanion.Repo
  import Ecto.Query

  def prepare_round(week, round_nr, ally_code) do
    [year, month, day] =
      week
      |> String.split("_")
      |> Enum.map(&String.to_integer/1)

    {:ok, date} = Date.new(year, month, day)

    round =
      from(
        round in Repo.GACRound,
        where: round.week == ^week and round.round == ^round_nr
      )
      |> Repo.one!()

    roster =
      from(
        roster in Repo.GACRoster,
        where: roster.ally_code == ^ally_code and roster.computed_at_date >= ^date,
        order_by: [desc: roster.computed_at_date],
        limit: 1
      )
      |> Repo.one!()

    Repo.GACRoundRoster.changeset(round, roster, %{})
    |> Repo.insert!()
  end
end
