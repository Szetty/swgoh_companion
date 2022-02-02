defmodule SWGOHCompanionWeb.PageController do
  use SWGOHCompanionWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
