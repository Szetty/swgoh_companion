defmodule SWGOHCompanion.SDK.SWGOHGG do
  alias SWGOHCompanion.SDK.HTTP

  @player "473362279"
  @percentage_threshold 10

  @characters_url "https://swgoh.gg/api/characters"
  @player_url "https://swgoh.gg/api/player"

  def get_all_characters() do
    IO.puts("Fetching characters")

    HTTP.get_json(@characters_url)
  end

  def get_player_roster(player \\ @player) do
    IO.puts("Fetching roster")

    @player_url
    |> Path.join(player)
    |> HTTP.get_json()
    |> Map.get("units")
  end

  @spec get_most_popular_mods([any()]) :: stream :: Enum.t()
  def get_most_popular_mods(characters \\ get_all_characters()) do
    characters
    |> Enum.map(fn %{"name" => name, "url" => url} -> {name, url} end)
    |> Stream.map(fn {name, character_url_path} ->
      {:ok, document} =
        character_url_path
        |> get_mod_recommendation()
        |> Floki.parse_document()

      [mod_sets | mod_slots] =
        Floki.find(document, "div.content-container-primary > ul > li.media")

      mod_sets =
        mod_sets
        |> Floki.find("tbody > tr")
        |> Enum.map(fn tr ->
          [sets, _count, percentage] = Floki.find(tr, "td")

          sets =
            sets
            |> Floki.find("div[data-title]")
            |> Enum.map(fn div ->
              div
              |> Floki.attribute("div", "data-title")
              |> hd()
              |> String.replace(~r/Set Bonus: \d+% /, "")
            end)

          percentage =
            percentage
            |> Floki.text()
            |> String.trim_trailing("%")
            |> String.to_integer()

          {sets, percentage}
        end)

      mod_slots =
        mod_slots
        |> Enum.map(fn mod_slot_html ->
          mod_slot_html
          |> Floki.find("tbody > tr")
          |> Enum.map(fn tr ->
            [name, _count, percentage] =
              tr
              |> Floki.find("td")
              |> Enum.map(&Floki.text/1)

            percentage =
              percentage
              |> String.trim_trailing("%")
              |> String.to_integer()

            {name, percentage}
          end)
        end)

      {name, mod_sets, mod_slots}
    end)
    |> Stream.map(fn {name, mod_sets, mod_slots} ->
      relevant_mod_sets =
        Enum.filter(mod_sets, fn {_, percentage} -> percentage > @percentage_threshold end)

      [relevant_receivers, relevant_data_buses, relevant_holo_arrays, relevant_multiplexers] =
        Enum.map(mod_slots, fn primary_mods ->
          Enum.filter(primary_mods, fn {_, percentage} -> percentage > @percentage_threshold end)
        end)

      {
        name,
        relevant_mod_sets,
        relevant_receivers,
        relevant_data_buses,
        relevant_holo_arrays,
        relevant_multiplexers
      }
    end)
  end

  def get_mod_recommendation(base_url) do
    base_url
    |> Path.join("/data/mods?filter_type=guilds_100_raid")
    |> HTTP.get_http_body()
  end
end
