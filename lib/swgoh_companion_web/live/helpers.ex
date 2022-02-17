defmodule SWGOHCompanionWeb.Live.Helpers do
  import Phoenix.LiveView
  import Phoenix.LiveView.Helpers

  alias SWGOHCompanionWeb.Router.Helpers, as: Routes

  @endpoint SWGOHCompanionWeb.Endpoint

  def home_path(nil = _current_user), do: "/"
  def home_path(_current_user), do: Routes.home_path(@endpoint, :home)

  def link(%{navigate: _to} = assigns) do
    assigns = assign_new(assigns, :class, fn -> nil end)

    ~H"""
    <a href={@navigate} data-phx-link="redirect" data-phx-link-state="push" class={@class}>
      <%= render_slot(@inner_block) %>
    </a>
    """
  end

  def link(%{patch: to} = assigns) do
    opts = assigns |> assigns_to_attributes() |> Keyword.put(:to, to)
    assigns = assign(assigns, :opts, opts)

    ~H"""
    <%= live_patch @opts do %><%= render_slot(@inner_block) %><% end %>
    """
  end

  def link(%{} = assigns) do
    opts = assigns |> assigns_to_attributes() |> Keyword.put(:to, assigns[:href] || "#")
    assigns = assign(assigns, :opts, opts)

    ~H"""
    <%= Phoenix.HTML.Link.link @opts do %><%= render_slot(@inner_block) %><% end %>
    """
  end
end
