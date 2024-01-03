defmodule SWGOHCompanion.Repo.GACRoster do
  alias __MODULE__
  use Ecto.Schema
  alias SWGOHCompanion.Repo
  import Ecto.Changeset

  schema "gac_rosters" do
    belongs_to :account, Repo.Account,
      foreign_key: :ally_code,
      references: :ally_code,
      type: :string

    field :computed_at_date, :date
    field :characters, {:array, :map}
    field :stats, :map, default: %{}

    has_many :gac_teams, Repo.GACTeam

    timestamps(updated_at: false)
  end

  def changeset(gac_roster \\ %GACRoster{}, attrs) do
    gac_roster
    |> cast(attrs, [:characters, :stats])
    |> validate_required([:ally_code, :characters])
    |> prepare_changes(&add_computed_at_date/1)
  end

  defp add_computed_at_date(changeset) do
    changeset
    |> put_change(:computed_at_date, Date.utc_today())
  end
end
