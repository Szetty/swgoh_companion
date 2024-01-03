defmodule SWGOHCompanion.Repo.GACRound do
  alias __MODULE__
  use Ecto.Schema
  import Ecto.Changeset
  alias SWGOHCompanion.Repo

  @primary_key false
  schema "gac_rounds" do
    field :id, :string, primary_key: true
    field :week, :string
    field :week_nr, :integer
    field :round, :integer
    field :gac_nr, :integer

    has_many :gac_round_rosters, Repo.GACRoundRoster, references: :id
    has_many :gac_rosters, through: [:gac_round_rosters, :gac_roster]

    timestamps(updated_at: false)
  end

  def changeset(gac_round \\ %GACRound{}, attrs) do
    gac_round
    |> cast(attrs, [:round, :week, :week_nr, :gac_nr])
    |> validate_required([:round, :week, :week_nr, :gac_nr])
    |> unique_constraint([:week, :round])
    |> unique_constraint([:gac_nr, :week_nr, :round])
    |> prepare_changes(&compute_id/1)
  end

  defp compute_id(changeset) do
    week = get_change(changeset, :week)
    round = get_change(changeset, :round)

    changeset
    |> put_change(:id, "#{week}.#{round}")
  end
end
