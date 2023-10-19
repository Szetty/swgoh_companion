defmodule SWGOHCompanion.SDK.Models.GAC do
  defmodule Bracket do
    @derive Jason.Encoder
    defstruct [
      # 2022_02_10
      :week,
      # 24
      :gac_nr,
      # DateTime.t()
      :start_time,
      # [String.t()]
      ally_codes: []
    ]
  end
end
