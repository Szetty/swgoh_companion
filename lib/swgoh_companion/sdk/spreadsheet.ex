defmodule SWGOHCompanion.SDK.Spreadsheet do
  @spreadsheet_id "150BDpFikpfnr9AyeDDgp2PbqAB6KyatRr-dAMnXtrjc"

  defmacro __using__([]) do
    quote do
      alias SWGOHCompanion.SDK.Spreadsheet
      import Spreadsheet
      @behaviour Spreadsheet.Writeable

      defp write_rows(sheet \\ open_spreadsheet(@sheet_name), rows) do
        rows
        |> to_spreadsheet_rows()
        |> (fn rows ->
              write_spreadsheet_rows(
                sheet,
                rows,
                @starting_row,
                @starting_column
              )
            end).()
      end
    end
  end

  def open_spreadsheet(sheet_name) do
    {:ok, pid} = GSS.Spreadsheet.Supervisor.spreadsheet(@spreadsheet_id, list_name: sheet_name)
    pid
  end

  def read_spreadsheet_rows(sheet, ranges) do
    {:ok, data} = GSS.Spreadsheet.read_rows(sheet, ranges)
    data
  end

  def write_spreadsheet_rows(_, [], _, _), do: IO.puts("Empty rows, nothing to update")

  def write_spreadsheet_rows(sheet, rows, starting_row, starting_column) do
    rows_count = Enum.count(rows)
    columns_count = rows |> Enum.map(&Enum.count/1) |> Enum.max(fn -> 0 end)

    ending_column =
      number_to_column_letter(columns_count + column_letter_to_number(starting_column) - 1)

    IO.puts(
      "Updating the sheet, ranges: #{starting_column}#{starting_row}:#{ending_column}#{starting_row + rows_count - 2}"
    )

    ranges =
      Enum.map(
        0..(rows_count - 1),
        &"#{starting_column}#{starting_row + &1}:#{ending_column}#{starting_row + &1}"
      )

    GSS.Spreadsheet.write_rows(sheet, ranges, rows)
  end

  defp column_letter_to_number(letter), do: letter |> String.to_charlist() |> hd
  defp number_to_column_letter(number), do: number |> List.wrap() |> List.to_string()
end
