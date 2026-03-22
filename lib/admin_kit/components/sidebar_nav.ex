defmodule AdminKit.Components.SidebarNav do
  @moduledoc "Stateful sidebar navigation component."
  use Phoenix.LiveComponent

  @impl true
  def render(assigns) do
    ~H"""
    <nav class="ak-sidebar-nav">
      <.link navigate="/" class="ak-sidebar-link ak-sidebar-dashboard">
        Dashboard
      </.link>
      <%= for resource <- @resources do %>
        <.link
          navigate={"/#{resource.plural_name}"}
          class={"ak-sidebar-link #{if @current_resource == resource.plural_name, do: "ak-sidebar-active"}"}
        >
          <%= String.capitalize(resource.plural_name) %>
        </.link>
      <% end %>
    </nav>
    """
  end
end
