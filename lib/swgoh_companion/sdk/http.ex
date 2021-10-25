defmodule SWGOHCompanion.SDK.HTTP do
  use Tesla

  plug(Tesla.Middleware.FollowRedirects)

  def get_json(url) do
    url
    |> get_http_body()
    |> Jason.decode!()
  end

  def get_http_body(url) do
    url
    |> get!()
    |> Map.get(:body)
  end
end
