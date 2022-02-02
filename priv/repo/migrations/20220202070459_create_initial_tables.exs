defmodule SWGOHCompanion.Repo.Migrations.CreateInitialTables do
  use Ecto.Migration

  def change do
    create table(:accounts, primary_key: false) do
      add :ally_code, :string, primary_key: true
      add :name, :string, null: false
      add :guild_name, :string, null: false

      timestamps()
    end

    create table(:gac_rosters) do
      add :ally_code,
          references(:accounts, column: :ally_code, on_delete: :delete_all, type: :string),
          null: false

      add :computed_at_date, :date, null: false
      add :characters, {:array, :map}, null: false
      add :stats, :map, null: false, default: %{}

      timestamps(updated_at: false)
    end

    create unique_index(:gac_rosters, [:ally_code, :computed_at_date])

    create table(:gac_teams) do
      add :gac_roster_id, references(:gac_rosters, on_delete: :delete_all), null: false
      add :leader_acronym, :string, null: false
      add :characters, {:array, :map}, null: false
      add :stats, :map, null: false, default: %{}

      timestamps(updated_at: false)
    end

    create table(:gac_rounds, primary_key: false) do
      add :id, :string, primary_key: true
      add :week, :string, null: false
      add :week_nr, :integer, null: false
      add :round, :integer, null: false
      add :gac_nr, :integer, null: false

      timestamps(updated_at: false)
    end

    create unique_index(:gac_rounds, [:week, :round])
    create unique_index(:gac_rounds, [:gac_nr, :week_nr, :round])

    create table(:gac_round_rosters) do
      add :gac_round_id, references(:gac_rounds, on_delete: :delete_all, type: :string),
        null: false

      add :gac_roster_id, references(:gac_rosters, on_delete: :delete_all), null: false

      timestamps(updated_at: false)
    end

    create unique_index(:gac_round_rosters, [:gac_round_id, :gac_roster_id])

    create table(:gac_round_teams) do
      add :gac_round_id, references(:gac_rounds, on_delete: :delete_all, type: :string),
        null: false

      add :gac_team_id, references(:gac_teams, on_delete: :delete_all), null: false

      timestamps(updated_at: false)
    end

    create unique_index(:gac_round_teams, [:gac_round_id, :gac_team_id])
  end
end
