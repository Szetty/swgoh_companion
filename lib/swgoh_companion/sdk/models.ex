defmodule SWGOHCompanion.SDK.Models do
  defmodule PlayerData do
    @derive Jason.Encoder
    defstruct characters: []
  end

  defmodule Character do
    alias SWGOHCompanion.SDK.Models.{Stats, Mod, Gear, Ability}
    @derive Jason.Encoder
    defstruct [
      :id, # GENERALSKYWALKER
      :name, # General Skywalker
      :power, # 12345
      :stats, # Stats
      :mod_stats, # Stats
      :mods, # [Mod]
      :gear, # Gear
      :relic_tier, # 5
      :zeta_abilities, # [Ability]
      :omicron_abilities # [Ability]
    ]

    def new(map) do
      Kernel.struct!(__MODULE__, map)
      |> then(fn
        %{stats: stats} = s when is_map(stats) -> %{s | stats: Stats.new(stats)}
        r -> r
      end)
      |> then(fn
        %{mod_stats: mod_stats} = s when is_map(mod_stats) -> %{s | mod_stats: Stats.new(mod_stats)}
        r -> r
      end)
      |> then(fn
        %{mods: mods} = s when is_list(mods) -> %{s | mods: Enum.map(mods, &Mod.new/1)}
        r -> r
      end)
      |> then(fn
        %{gear: gear} = s when is_map(gear) -> %{s | gear: Gear.new(gear)}
        r -> r
      end)
      |> then(fn
        %{zeta_abilities: zeta_abilities} = s when is_list(zeta_abilities) -> %{s | zeta_abilities: Enum.map(zeta_abilities, &Ability.new/1)}
        r -> r
      end)
      |> then(fn
        %{omicron_abilities: omicron_abilities} = s when is_list(omicron_abilities) -> %{s | omicron_abilities: Enum.map(omicron_abilities, &Ability.new/1)}
        r -> r
      end)
    end

    def empty(name) do
      name =
        if first_character_lowercase?(name) do
          name
          |> String.split(" ")
          |> Enum.map(&String.capitalize/1)
          |> Enum.join(" ")
        else
          name
        end

      %__MODULE__{
        id: nil,
        name: name,
        power: 0,
        stats: Stats.empty(),
        mod_stats: Stats.empty(),
        mods: [],
        gear: Gear.empty(),
        relic_tier: 0,
        zeta_abilities: [],
        omicron_abilities: []
      }
    end

    defp first_character_lowercase?(name) do
      first_character_string = String.slice(name, 0..0)
      String.downcase(first_character_string) == first_character_string
    end
  end

  defmodule Stats do
    @derive Jason.Encoder
    defstruct [:speed]

    def new(map) do
      Kernel.struct!(__MODULE__, map)
    end

    def empty do
      %__MODULE__{speed: 0}
    end
  end

  defmodule Mod do
    @derive Jason.Encoder
    defstruct [
      :tier,
      :rarity,
      :level,
      :primary_stat_name,
      :primary_stats,
      :set_stat_name,
      :secondary_stats,
      :slot
    ]

    def new(map) do
      Kernel.struct!(__MODULE__, map)
    end
  end

  defmodule Gear do
    @derive Jason.Encoder
    defstruct [
      :level,
      :count
    ]

    def new(map) do
      Kernel.struct!(__MODULE__, map)
    end

    def empty do
      %__MODULE__{level: 0, count: 0}
    end
  end

  defmodule Ability do
    @derive Jason.Encoder
    defstruct [
      :name, # Hero with no Fear
      :type, # unique
      :order # 2
    ]

    def new(map) do
      Kernel.struct!(__MODULE__, map)
    end
  end
end
