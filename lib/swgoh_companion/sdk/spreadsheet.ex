defmodule SWGOHCompanion.SDK.Spreadsheet do
  @spreadsheet_id "150BDpFikpfnr9AyeDDgp2PbqAB6KyatRr-dAMnXtrjc"

  defmacro __using__([]) do
    quote do
      alias SWGOHCompanion.SDK.Spreadsheet
      import Spreadsheet
      @behaviour Spreadsheet.Writeable

      defp write_rows(rows, opts \\ []) do
        starting_row = Keyword.get(opts, :starting_row, @starting_row)
        starting_column = Keyword.get(opts, :starting_column, @starting_column)
        sheet_name = Keyword.get(opts, :sheet_name, @sheet_name)
        clear_range = Keyword.get(opts, :clear_range)

        sheet = get_or_open_sheet(sheet_name, opts)

        if clear_range do
          GSS.Spreadsheet.clear_rows(sheet, [clear_range])
        end

        rows
        |> to_spreadsheet_rows()
        |> then(
          &write_spreadsheet_rows(
            sheet,
            &1,
            starting_row,
            starting_column
          )
        )
      end

      defp read_spreadsheet_rows(ranges, opts \\ []) do
        sheet_name = Keyword.get(opts, :sheet_name, @sheet_name)

        sheet = get_or_open_sheet(sheet_name, opts)
        {:ok, data} = GSS.Spreadsheet.read_rows(sheet, ranges)
        data
      end
    end
  end

  def get_or_open_sheet(sheet_name, opts \\ []) do
    spreadsheet_id = Keyword.get(opts, :spreadsheet_id, @spreadsheet_id)
    sheet_pid_name = String.to_atom(sheet_name)

    case Process.whereis(sheet_pid_name) do
      pid when is_pid(pid) ->
        pid

      nil ->
        {:ok, pid} =
          GSS.Spreadsheet.Supervisor.spreadsheet(spreadsheet_id, list_name: sheet_name)

        Process.register(pid, sheet_pid_name)
        pid
    end
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

    GSS.Spreadsheet.write_rows(sheet, ranges, rows, recv_timeout: 10_000)
    # File.write!("1.csv", rows |> Enum.map(&Enum.join(&1, ",")) |> Enum.join("\n"))
  end

  defp column_letter_to_number(letter), do: letter |> String.to_charlist() |> hd
  defp number_to_column_letter(number), do: number |> List.wrap() |> List.to_string()
end
