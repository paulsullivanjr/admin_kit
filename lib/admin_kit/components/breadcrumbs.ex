defmodule AdminKit.Components.Breadcrumbs do
  @moduledoc "Stateful breadcrumb navigation component."
  use Phoenix.LiveComponent

  @impl true
  def render(assigns) do
    ~H"""
    <nav class="ak-breadcrumbs" aria-label="Breadcrumbs">
      <ol class="ak-breadcrumb-list">
        <%= for {label, path} <- @items do %>
          <li class="ak-breadcrumb-item">
            <%= if path do %>
              <.link navigate={path} class="ak-breadcrumb-link"><%= label %></.link>
            <% else %>
              <span class="ak-breadcrumb-current"><%= label %></span>
            <% end %>
          </li>
        <% end %>
      </ol>
    </nav>
    """
  end
end
