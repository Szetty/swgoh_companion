defmodule SWGOHCompanion.Repo do
  use Ecto.Repo,
    otp_app: :swgoh_companion,
    adapter: Ecto.Adapters.Postgres
end
