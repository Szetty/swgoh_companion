defmodule SWGOHCompanion.SDK.HTTP do
  use Tesla

  plug(Tesla.Middleware.FollowRedirects)

  def get_json(url, headers \\ []) do
    url
    |> get_http_body(headers)
    |> Jason.decode!()
  end

  def get_http_body(url, headers \\ []) do
    url
    |> get!(headers: headers)
    |> Map.get(:body)
  end
end
