defmodule SWGOHCompanion.Hunters.UpsertGears do
  @sheet_name "Gears"
  @starting_row 2
  @starting_column "A"

  use SWGOHCompanion.SDK, spreadsheet: true

  def upsert_gears do
    character_name_by_id =
      SDK.get_all_characters()
      |> Enum.into(%{}, fn %{"base_id" => id, "name" => name} ->
        {id, name}
      end)

    %PlayerData{characters: characters} = SDK.get_all_player_data()

    gear_by_character_id =
      characters
      |> Enum.map(fn %Character{
                       id: id,
                       gear: %Gear{
                         level: level,
                         count: count
                       }
                     } ->
        {id, %{gear: level * 10 + count}}
      end)
      |> Map.new()

    character_name_by_id
    |> Enum.map(fn {id, name} ->
      case Map.get(gear_by_character_id, id) do
        %{gear: gear} ->
          {name, gear}

        nil ->
          {name, 0}
      end
    end)
    |> Enum.sort_by(fn {_name, gear} -> -gear end)
    |> write_rows()
  end

  def to_spreadsheet_rows(data) do
    data
    |> Enum.map(fn {name, gear} ->
      [name, gear]
    end)
  end
end
