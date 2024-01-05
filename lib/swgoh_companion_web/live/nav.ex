defmodule SWGOHCompanionWeb.Nav do
  # import Phoenix.LiveView

  def on_mount(:default, _params, _session, socket) do
    socket = socket
    # |> attach_hook(:active_tab, :handle_params, &handle_active_tab_params/3)

    {:cont, socket}
  end

  # defp handle_active_tab_params(params, _url, socket) do
  #   active_tab =
  #     case {socket.view, socket.assigns.live_action} do
  #       {ProfileLive, _} ->
  #         if params["profile_username"] == current_user_profile_username(socket) do
  #           :profile
  #         end

  #       {SettingsLive, _} ->
  #         :settings

  #       {_, _} ->
  #         nil
  #     end

  #   {:cont, assign(socket, active_tab: active_tab)}
  # end

  # defp current_user_profile_username(socket) do
  #   if user = socket.assigns.current_user do
  #     user.username
  #   end
  # end
end
