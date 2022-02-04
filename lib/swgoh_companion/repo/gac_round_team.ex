defmodule SWGOHCompanion.Repo.GACRoundTeam do
  alias __MODULE__
  use Ecto.Schema
  alias SWGOHCompanion.Repo
  import Ecto.Changeset

  schema "gac_round_teams" do
    belongs_to :gac_round, Repo.GACRound, type: :string
    belongs_to :gac_team, Repo.GACTeam

    timestamps(updated_at: false)
  end

  def changeset(
        gac_round_team \\ %GACRoundTeam{},
        %Repo.GACRound{} = gac_round,
        %Repo.GACTeam{} = gac_team,
        attrs
      ) do
    gac_round_team
    |> cast(attrs, [])
    |> put_assoc(:gac_round, gac_round)
    |> put_assoc(:gac_team, gac_team)
  end
end
