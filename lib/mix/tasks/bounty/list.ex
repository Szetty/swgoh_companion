defmodule Mix.Tasks.Bounty.List do
  @moduledoc "Will list all bounties that our hunters are currently hunting"
  @shortdoc "Lists Bounties"

  use Mix.Task

  @impl Mix.Task
  def run(_args) do
    bounties =
      "lib/swgoh_companion/hunters"
      |> File.ls!()
      |> Enum.map(&String.replace_leading(&1, "upsert_", ""))
      |> Enum.map(&Path.rootname/1)
      |> Enum.map(&Macro.camelize/1)
      |> Enum.join("\n")

    Mix.shell().info("The bounties are:\n#{bounties}")
  end
end
