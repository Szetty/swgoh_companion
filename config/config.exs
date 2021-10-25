use Mix.Config

config :goth, :json, File.read!("./service-account.json")

config :elixir_google_spreadsheets, :client,
  request_workers: 50,
  max_demand: 100,
  max_interval: :timer.minutes(1),
  interval: 100,
  max_rows_per_request: 150

config :logger,
  level: :warn
