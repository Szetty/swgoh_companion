defmodule SWGOHCompanion.Hunters.UpsertInqs do
  @sheet_name "Data"
  @starting_row 4
  @starting_column "A"
  @spreadsheet_id "10uUn3sGOKebIZs2Tc5DZq3N4VQIXtPem2nriY2zdE6o"
  @guild_id "WTdY4n5eRpS-SB7Y271TBw"
  @inqs [
    "Grand Inquisitor",
    "Seventh Sister",
    "Fifth Brother",
    "Eighth Brother",
    "Ninth Sister",
    "Second Sister"
  ]

  use SWGOHCompanion.SDK, spreadsheet: true

  def upsert_inqs do
    %GuildProfile{members: members} = SDK.get_guild_profile(@guild_id)

    members
    |> Enum.map(fn %GuildMember{player_name: player_name, ally_code: ally_code} ->
      %PlayerData{characters: characters} = SDK.get_player(ally_code)
      characters_by_name = Enum.into(characters, %{}, &{&1.name, &1})

      [player_name] ++
        Enum.map(
          @inqs,
          &case characters_by_name[&1] do
            nil -> "N/A"
            %Character{relic_tier: relic_tier} -> relic_tier
          end
        )
    end)
    |> Enum.sort_by(fn [_player_name | rest] ->
      Enum.map(rest, fn
        i when is_integer(i) -> -i
        _ -> 1
      end)
    end)
    |> write_rows(spreadsheet_id: @spreadsheet_id)
  end

  def to_spreadsheet_rows(data) do
    data
  end
end
