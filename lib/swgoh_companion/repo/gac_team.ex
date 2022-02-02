defmodule SWGOHCompanion.Repo.GACTeam do
  use Ecto.Schema
  alias SWGOHCompanion.Repo

  schema "gac_teams" do
    belongs_to :gac_roster, Repo.GACRoster
    field :leader_acronym, :string, null: false
    field :characters, {:array, :map}, null: false
    field :stats, :map, null: false, default: %{}

    timestamps(updated_at: false)
  end
end
