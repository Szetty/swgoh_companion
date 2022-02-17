defmodule SWGOHCompanion.Hunters.GAC.PrepareWeek do
  use SWGOHCompanion.SDK
  alias SWGOHCompanion.Repo
  alias SDK.Models.PlayerData
  alias Ecto.Multi
  import Ecto.Query

  @rounds 1..3

  def prepare_week(week, gac_nr, week_nr, ally_codes) do
    ally_codes =
      ally_codes
      |> Enum.map(&"#{&1}")

    {:ok, _} =
      Multi.new()
      |> fetch_and_save_players(ally_codes)
      |> prepare_gac_rounds(week, gac_nr, week_nr)
      |> prepare_current_user_roster(week)
      |> SWGOHCompanion.Repo.transaction()
  end

  defp fetch_and_save_players(multi, ally_codes) do
    ally_codes
    |> Enum.reject(&(&1 == SDK.current_user_ally_code()))
    |> Enum.reduce(multi, fn ally_code, multi ->
      %PlayerData{name: player_name, guild_name: guild_name, characters: characters} =
        SDK.get_player(ally_code)

      insert_account_operation_name = :"insert_account_#{ally_code}"

      insert_gac_roster_fn = fn %{^insert_account_operation_name => account} ->
        account
        |> Ecto.build_assoc(:gac_rosters)
        |> Repo.GACRoster.changeset(%{characters: characters})
      end

      multi
      |> Multi.insert(
        insert_account_operation_name,
        Repo.Account.changeset(%{ally_code: ally_code, name: player_name, guild_name: guild_name}),
        conflict_target: [:ally_code],
        on_conflict: {:replace, [:name, :guild_name, :updated_at]}
      )
      |> Multi.insert(
        gac_roster_operation_name(ally_code),
        insert_gac_roster_fn,
        conflict_target: [:ally_code, :computed_at_date],
        # Workaround to read fields from db
        on_conflict: {:replace, [:ally_code]}
      )
    end)
  end

  defp prepare_gac_rounds(multi, week, gac_nr, week_nr) do
    @rounds
    |> Enum.reduce(multi, fn r, multi ->
      Multi.insert(
        multi,
        round_operation_name(r),
        Repo.GACRound.changeset(%Repo.GACRound{round: r}, %{
          week: week,
          gac_nr: gac_nr,
          week_nr: week_nr
        }),
        conflict_target: [:id],
        # Workaround to read fields from db
        on_conflict: {:replace, [:week]}
      )
    end)
  end

  defp prepare_current_user_roster(multi, week) do
    ally_code = SDK.current_user_ally_code()

    if gac_week_has_roster_from_account?(week, ally_code) do
      multi
    else
      account = Repo.get!(Repo.Account, ally_code)

      %PlayerData{characters: characters} = SDK.get_player(ally_code)

      multi =
        Multi.insert(
          multi,
          gac_roster_operation_name(ally_code),
          account
          |> Ecto.build_assoc(:gac_rosters)
          |> Repo.GACRoster.changeset(%{characters: characters}),
          conflict_target: [:ally_code, :computed_at_date],
          # Workaround to read fields from db
          on_conflict: {:replace, [:ally_code]}
        )

      @rounds
      |> Enum.reduce(multi, fn r, multi ->
        insert_gac_round_roster_fn = fn multi ->
          round = Map.get(multi, round_operation_name(r))
          roster = Map.get(multi, gac_roster_operation_name(ally_code))

          Repo.GACRoundRoster.changeset(round, roster, %{})
        end

        Multi.insert(
          multi,
          :"insert_gac_round_roster_#{r}_#{ally_code}",
          insert_gac_round_roster_fn,
          conflict_target: [:gac_roster_id, :gac_round_id],
          on_conflict: :nothing
        )
      end)
    end
  end

  defp round_operation_name(r), do: :"insert_gac_round_#{r}"

  defp gac_roster_operation_name(ally_code), do: :"insert_gac_roster_#{ally_code}"

  defp gac_week_has_roster_from_account?(week, ally_code) do
    from(
      gac_round_roster in Repo.GACRoundRoster,
      where: like(gac_round_roster.gac_round_id, ^"#{week}%"),
      join: gac_roster in Repo.GACRoster,
      on: gac_round_roster.gac_roster_id == gac_roster.id,
      where: gac_roster.ally_code == ^ally_code
    )
    |> Repo.aggregate(:count)
    |> Kernel.>(0)
  end
end
