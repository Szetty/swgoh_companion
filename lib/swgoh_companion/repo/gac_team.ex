defmodule SWGOHCompanion.Repo.GACTeam do
  alias __MODULE__
  use Ecto.Schema
  alias SWGOHCompanion.Repo
  import Ecto.Changeset

  schema "gac_teams" do
    belongs_to :gac_roster, Repo.GACRoster
    field :leader_acronym, :string
    field :characters, {:array, :map}
    field :stats, :map, default: %{}

    timestamps(updated_at: false)
  end

  def changeset(gac_team \\ %GACTeam{}, attrs) do
    gac_team
    |> cast(attrs, [:characters, :leader_acronym, :stats])
    |> validate_required([:gac_roster_id, :characters, :leader_acronym])
  end
end
