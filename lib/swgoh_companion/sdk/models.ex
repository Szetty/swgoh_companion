defmodule SWGOHCompanion.SDK.Models do
  defmodule PlayerData do
    @derive Jason.Encoder
    defstruct characters: []
  end

  defmodule Character do
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
  end

  defmodule Stats do
    @derive Jason.Encoder
    defstruct [:speed]
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
  end

  defmodule Gear do
    @derive Jason.Encoder
    defstruct [
      :level,
      :count
    ]
  end

  defmodule Ability do
    @derive Jason.Encoder
    defstruct [
      :name, # Hero with no Fear
      :type, # unique
      :order # 2
    ]
  end
end
