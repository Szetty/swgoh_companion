defmodule SWGOHCompanionWeb.OAuthCallbackController do
  use SWGOHCompanionWeb, :controller
  require Logger

  def new(conn, %{}) do
    user = SWGOHCompanion.SDK.current_user_ally_code()

    conn
    |> put_flash(:info, "Welcome")
    |> SWGOHCompanionWeb.UserAuth.log_in_user(user)
  end
end
