defmodule SWGOHCompanion.SDK.HTTP do
  use Tesla

  plug(Tesla.Middleware.FollowRedirects)

  def get_json(url, headers \\ []) do
    url
    |> get_http_body(headers)
    |> then(fn resp ->
      resp
      |> Jason.decode()
      |> case do
        {:ok, json} ->
          json

        {:error, reason} ->
          raise("Error with #{inspect(reason)} for #{resp}")
      end
    end)
  end

  def get_http_body(url, headers \\ []) do
    url
    |> get!(headers: headers)
    |> Map.get(:body)
  end
end
