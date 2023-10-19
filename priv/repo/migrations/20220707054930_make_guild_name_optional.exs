defmodule SWGOHCompanion.Repo.Migrations.MakeGuildNameOptional do
  use Ecto.Migration

  def change do
    alter table(:accounts) do
      modify :guild_name, :string, null: true
    end
  end
end
