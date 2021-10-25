defmodule SWGOHCompanion.MixProject do
  use Mix.Project

  def project do
    [
      app: :swgoh_helpers,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {SWGOHCompanion.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:elixir_google_spreadsheets, "~> 0.1.17"},
      {:jason, "~> 1.2"},
      {:tesla, "~> 1.4"},
      {:floki, "~> 0.31.0"}
    ]
  end
end
