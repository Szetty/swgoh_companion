defmodule SWGOHCompanion.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      SWGOHCompanion.Repo,
      # Start the Telemetry supervisor
      SWGOHCompanionWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: SWGOHCompanion.PubSub},
      # Start the Endpoint (http/https)
      SWGOHCompanionWeb.Endpoint
      # Start a worker by calling: SWGOHCompanion.Worker.start_link(arg)
      # {SWGOHCompanion.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SWGOHCompanion.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SWGOHCompanionWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
