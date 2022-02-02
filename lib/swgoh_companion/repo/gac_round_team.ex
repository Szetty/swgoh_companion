defmodule SWGOHCompanion.Repo.GACRoundTeam do
  use Ecto.Schema
  alias SWGOHCompanion.Repo

  schema "gac_round_teams" do
    belongs_to :gac_round, Repo.GACRound, type: :string
    belongs_to :gac_team, Repo.GACTeam

    timestamps(updated_at: false)
  end
end
