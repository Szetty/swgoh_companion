# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :elixir_google_spreadsheets, json: "./service-account.json" |> File.read!

config :elixir_google_spreadsheets, :client,
  request_workers: 1,
  max_demand: 10,
  max_interval: :timer.minutes(1),
  interval: 100,
  max_rows_per_request: 150

config :swgoh_companion,
  namespace: SWGOHCompanion,
  ecto_repos: [SWGOHCompanion.Repo]

# Configures the endpoint
config :swgoh_companion, SWGOHCompanionWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: SWGOHCompanionWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: SWGOHCompanion.PubSub,
  live_view: [signing_salt: "J/TRWDSh"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.0",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: :all

config :logger,
  level: :debug

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :tailwind,
  version: "3.0.18",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
