defmodule SWGOHCompanionWeb.Router do
  use SWGOHCompanionWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {SWGOHCompanionWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SWGOHCompanionWeb do
    pipe_through :browser

    get "/", RedirectController, :redirect_authenticated
    get "/oauth/callbacks/", OAuthCallbackController, :new

    live_session :default,
      on_mount: [{SWGOHCompanionWeb.UserAuth, :current_user}, SWGOHCompanionWeb.Nav] do
      live "/signin", SignInLive, :index
    end

    live_session :authenticated,
      on_mount: [{SWGOHCompanionWeb.UserAuth, :ensure_authenticated}, SWGOHCompanionWeb.Nav] do
      live "/home", HomeLive, :home
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", SWGOHCompanionWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: SWGOHCompanionWeb.Telemetry
    end
  end
end
