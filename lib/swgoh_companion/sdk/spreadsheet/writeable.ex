defmodule SWGOHCompanion.SDK.Spreadsheet.Writeable do
  @doc """
  Transforms the data to format writeable to a spreadsheet.
  """
  @callback to_spreadsheet_rows(any()) :: [[any()]]
end
