defmodule SWGOHCompanion.Repo.Account do
  alias __MODULE__
  use Ecto.Schema
  import Ecto.Changeset
  alias SWGOHCompanion.Repo

  @primary_key false
  schema "accounts" do
    field :ally_code, :string, primary_key: true
    field :name, :string
    field :guild_name, :string

    has_many :gac_rosters, Repo.GACRoster, references: :ally_code, foreign_key: :ally_code

    timestamps()
  end

  def changeset(account \\ %Account{}, attrs) do
    account
    |> cast(attrs, [:ally_code, :name, :guild_name])
    |> validate_required([:ally_code, :name])
  end
end
