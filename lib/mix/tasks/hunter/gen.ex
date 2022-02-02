defmodule Mix.Tasks.Hunter.Gen do
  @shortdoc "Generates a new hunter"

  @moduledoc """
    #{@shortdoc}
    `mix hunter.gen <bounty_name> [--sheet sheet_name]`
  ## Arguments
  * bounty_name - the name of the bounty to be hunted, will be used for file, module and function names
  * sheet_name - name of the sheet from the configured spreadsheet
  """

  use Mix.Task

  defmodule Context do
    defstruct [
      :name,
      :name_camel_case,
      :sheet_name,
      :shell_template,
      :hunter_template,
      :defdelegate_template
    ]
  end

  @shell_template ~s"""
  #!/usr/bin/env sh

  set -xe

  mix run -e "SWGOHCompanion.%%NAME_SNAKE_CASE%%"
  """

  @hunter_template ~s"""
  defmodule SWGOHCompanion.Hunters.%%NAME_CAMEL_CASE%% do%%CONSTANTS%%%%IMPORTS%%
    def %%NAME_SNAKE_CASE%% do
      %%FUNCTION_BODY%%
    end
    %%OTHER_FUNCTIONS%%
  end
  """

  @spreadsheet_constants ~s"""

    @sheet_name "%%SHEET_NAME%%"
    @starting_row 2
    @starting_column "A"
  """

  @spreadsheet_imports ~s"""

    use SWGOHCompanion.SDK, spreadsheet: true
  """

  @spreadsheet_function_body "write_rows([])"

  @spreadsheet_other_functions ~s"""

    def to_spreadsheet_rows(_data) do
      []
    end
  """

  @no_spreadsheet_imports ~s"""

    use SWGOHCompanion.SDK
  """

  @defdelegate_template ~s"""
  defdelegate %%NAME_SNAKE_CASE%%, to: %%NAME_CAMEL_CASE%%
  """

  @impl Mix.Task
  def run(args) do
    {flags, [name], []} = OptionParser.parse(args, strict: [sheet: :string])

    sheet_name =
      case flags do
        [sheet: sheet_name] ->
          sheet_name

        _ ->
          nil
      end

    %Context{
      name: name,
      name_camel_case: Macro.camelize(name),
      sheet_name: sheet_name
    }
    |> generate_shell_script()
    |> generate_hunter_template()
    |> generate_defdelegate()
    |> create_files_and_print_info()
  end

  defp generate_shell_script(%Context{name: name} = context) do
    shell_template =
      @shell_template
      |> String.replace("%%NAME_SNAKE_CASE%%", name)

    %{context | shell_template: shell_template}
  end

  defp generate_hunter_template(
         %Context{
           name: name,
           name_camel_case: name_camel_case,
           sheet_name: sheet_name
         } = context
       ) do
    hunter_template =
      @hunter_template
      |> String.replace("%%NAME_SNAKE_CASE%%", name)
      |> String.replace("%%NAME_CAMEL_CASE%%", name_camel_case)
      |> apply_spreadsheet_on_hunter_template(sheet_name)

    %{context | hunter_template: hunter_template}
  end

  defp apply_spreadsheet_on_hunter_template(hunter_template, sheet_name) do
    if sheet_name != nil do
      constants = String.replace(@spreadsheet_constants, "%%SHEET_NAME%%", sheet_name)

      hunter_template
      |> String.replace("%%CONSTANTS%%", constants)
      |> String.replace("%%IMPORTS%%", @spreadsheet_imports)
      |> String.replace("%%FUNCTION_BODY%%", @spreadsheet_function_body)
      |> String.replace("%%OTHER_FUNCTIONS%%", @spreadsheet_other_functions)
    else
      hunter_template
      |> String.replace("%%CONSTANTS%%", "")
      |> String.replace("%%IMPORTS%%", @no_spreadsheet_imports)
      |> String.replace("%%FUNCTION_BODY%%", "[]")
      |> String.replace("%%OTHER_FUNCTIONS%%", "")
    end
  end

  defp generate_defdelegate(%Context{name: name, name_camel_case: name_camel_case} = context) do
    defdelegate_template =
      @defdelegate_template
      |> String.replace("%%NAME_SNAKE_CASE%%", name)
      |> String.replace("%%NAME_CAMEL_CASE%%", name_camel_case)

    %{context | defdelegate_template: defdelegate_template}
  end

  defp create_files_and_print_info(%Context{
         name: name,
         name_camel_case: name_camel_case,
         shell_template: shell_template,
         hunter_template: hunter_template,
         defdelegate_template: defdelegate_template
       }) do
    shell_path = "bin/#{name}.sh"
    create_file!(shell_path, shell_template)
    create_file!("lib/swgoh_companion/hunters/#{name}.ex", hunter_template)

    Mix.shell().info(~s"""

    To finish configuring the new template, you will need to
    1. Alias the new module (SWGOHCompanion.Hunters.#{name_camel_case})
    2. Add the following line in the main file (lib/swgoh_companion.ex):

      #{defdelegate_template}

    3. Give execution permissions to #{shell_path}:

      chmod +x #{shell_path}

    """)
  end

  def create_file!(name, content) do
    File.write!(name, content)
    Mix.shell().info("Generated #{name}")
  end
end
