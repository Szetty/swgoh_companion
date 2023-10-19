defmodule SWGOHCompanion.Hunters.UpsertMissingGearCount do
  @sheet_name "To Focus"
  @starting_row 2
  @starting_column "K"

  use SWGOHCompanion.SDK, spreadsheet: true
  alias SDK.HTTP

  @interested_gear_pieces %{
    "Mk 3 Carbanti" => [
      "Mk 3 Carbanti Sensor Array",
      "Mk 6 SoroSuub Keypad",
      "Mk 12 ArmaTek Thermal Detonator Component",
      "Mk 12 ArmaTek Thermal Detonator",
      "Mk 5 Merr-Sonn Thermal Detonator",
      "Mk 9 BAW Armor Mod",
      "Mk 8 Loronar Power Cell",
      "Mk 5 A/KT Stun Gun",
      "Mk 6 A/KT Stun Gun",
      "Mk 4 Czerka Stun Cuffs"
    ],
    "Kyrotech" => [
      "Mk 9 Kyrotech Battle Computer",
      "Mk 7 Kyrotech Power Converter",
      "Mk 7 Kyrotech Shock Prod"
    ],
    "Mk 8 BioTech Implant" => [
      "Mk 8 BioTech Implant",
      "Mk 6 A/KT Stun Gun"
    ]
  }
  @character_name_mappings %{
    "Obi-Wan Kenobi" => "Obi-Wan Kenobi (Old Ben)",
    "Fives" => "CT-5555 \"Fives\"",
    "Rex" => "CT-7567 \"Rex\"",
    "\"Echo\"" => "CT-21-0408 \"Echo\"",
    "Chirrut Imwe" => "Chirrut Îmwe",
    "Cody" => "CC-2224 \"Cody\"",
    "Mara Jade" => "Mara Jade, The Emperor's Hand",
    "SLKR" => "Supreme Leader Kylo Ren",
    "B1" => "B1 Battle Droid",
    "B2" => "B2 Super Battle Droid",
    "IG-86" => "IG-86 Sentinel Droid"
  }

  def upsert_missing_gear_count do
    %PlayerData{characters: characters} = SDK.get_player_roster()

    character_urls_by_name =
      characters
      |> Enum.into(%{}, fn %Character{
                             name: name,
                             url: url
                           } ->
        {name, url}
      end)

    ["B2:B"]
    |> read_spreadsheet_rows()
    |> Enum.map(fn
      [character] ->
        name = Map.get(@character_name_mappings, character, character)

        @interested_gear_pieces
        |> Enum.map(fn {_, gears} ->
          compute_missing_gear_count(gears, character_urls_by_name[name])
        end)

      [] ->
        []
    end)
    |> write_rows()
  end

  def to_spreadsheet_rows(data) do
    data
  end

  defp compute_missing_gear_count(gears, url) do
    url
    |> HTTP.get_http_body()
    |> Floki.parse_document!()
    |> Floki.find(".pc-needed-gear-list > .pc-needed-gear")
    |> Enum.map(fn needed_gear_html ->
      name =
        needed_gear_html
        |> Floki.find("span[data-original-title]")
        |> Floki.attribute("data-original-title")
        |> hd

      count =
        needed_gear_html
        |> Floki.find(".pc-needed-gear-count")
        |> Floki.text()
        |> String.to_integer()

      {name, count}
    end)
    |> Enum.filter(fn {name, _count} -> name in gears end)
    |> Enum.map(fn {_name, count} -> count end)
    |> Enum.sum()
  end
end
