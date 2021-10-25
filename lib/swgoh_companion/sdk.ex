defmodule SWGOHCompanion.SDK do
  defmacro __using__(opts \\ []) do
    use_spreadsheet? = Keyword.get(opts, :spreadsheet, false)

    common_quote =
      quote do
        alias SWGOHCompanion.SDK
        alias SDK.Models.{PlayerData, Character, Stats, Mod}
      end

    spreadsheet_quotes =
      if use_spreadsheet? do
        [
          quote do
            use SDK.Spreadsheet
          end
        ]
      else
        []
      end

    [common_quote] ++ spreadsheet_quotes
  end

  defdelegate get_all_characters, to: __MODULE__.SWGOHGG
  defdelegate get_player_roster, to: __MODULE__.SWGOHGG
  defdelegate get_most_popular_mods, to: __MODULE__.SWGOHGG

  defdelegate get_all_player_data, to: __MODULE__.Hotutils
end
