defmodule SWGOHCompanion.Repo.GACRoundRoster do
  alias __MODULE__
  use Ecto.Schema
  alias SWGOHCompanion.Repo
  import Ecto.Changeset

  schema "gac_round_rosters" do
    belongs_to :gac_round, Repo.GACRound, type: :string
    belongs_to :gac_roster, Repo.GACRoster

    timestamps(updated_at: false)
  end

  def changeset(
        gac_round_roster \\ %GACRoundRoster{},
        %Repo.GACRound{} = gac_round,
        %Repo.GACRoster{} = gac_roster,
        attrs
      ) do
    gac_round_roster
    |> cast(attrs, [])
    |> put_assoc(:gac_round, gac_round)
    |> put_assoc(:gac_roster, gac_roster)
  end
end
