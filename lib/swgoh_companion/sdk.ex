defmodule SWGOHCompanion.SDK do
  defmacro __using__(opts \\ []) do
    use_spreadsheet? = Keyword.get(opts, :spreadsheet, false)

    common_quote =
      quote do
        alias SWGOHCompanion.SDK
        alias SDK.Models.{PlayerData, Character, Stats, Mod, Gear, GAC}
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

  def current_user_ally_code, do: "473362279"

  defdelegate get_all_characters, to: __MODULE__.SWGOHGG
  defdelegate get_player(ally_code), to: __MODULE__.SWGOHGG
  defdelegate get_player_roster, to: __MODULE__.SWGOHGG
  defdelegate get_player_roster(ally_code), to: __MODULE__.SWGOHGG
  defdelegate get_most_popular_mods, to: __MODULE__.SWGOHGG

  defdelegate get_all_player_data, to: __MODULE__.Hotutils
  defdelegate get_current_gac_bracket(ally_code), to: __MODULE__.SWGOHGG

  def recursive_merge(_key \\ nil, term1, term2)

  def recursive_merge(_key, map1, map2) when is_map(map1) and is_map(map2) do
    Map.merge(map1, map2, &recursive_merge/3)
  end

  def recursive_merge(_key, list1, list2) when is_list(list1) and is_list(list2) do
    list1 ++ list2
  end
end
