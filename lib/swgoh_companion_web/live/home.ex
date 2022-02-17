defmodule SWGOHCompanionWeb.HomeLive do
  use SWGOHCompanionWeb, :live_view

  def render(assigns) do
    ~H"""
    Hello
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
