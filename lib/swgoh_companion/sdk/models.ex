defmodule SWGOHCompanion.SDK.Models do
  defmodule PlayerData do
    defstruct characters: []
  end

  defmodule Character do
    defstruct [
      :id,
      :power,
      :stats,
      :mod_stats,
      :mods,
      :gear
    ]
  end

  defmodule Stats do
    defstruct [:speed]
  end

  defmodule Mod do
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
    defstruct [
      :level,
      :count
    ]
  end
end
