defmodule AdminKit.Live.DashboardLive do
  @moduledoc "Dashboard LiveView showing summary cards for each registered resource."
  use Phoenix.LiveView

  alias AdminKit.Live.Helpers

  @impl true
  def mount(_params, session, socket) do
    admin_module = Helpers.get_admin_module(socket, session)
    resources = admin_module.__resources__()

    {:ok,
     assign(socket,
       admin_module: admin_module,
       resources: resources,
       page_title: "Dashboard"
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="ak-dashboard">
      <h1 class="ak-page-title">Dashboard</h1>
      <div class="ak-dashboard-grid">
        <%= for resource <- @resources do %>
          <div class="ak-card">
            <h3 class="ak-card-title"><%= String.capitalize(resource.plural_name) %></h3>
            <p class="ak-card-description">
              Manage <%= resource.plural_name %>
            </p>
            <.link navigate={"/#{resource.plural_name}"} class="ak-link">
              View all &rarr;
            </.link>
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end
