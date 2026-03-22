defmodule AdminKit.Components.FilterPanel do
  @moduledoc "Stateful filter panel component for scope switching."
  use Phoenix.LiveComponent

  @impl true
  def render(assigns) do
    ~H"""
    <div class="ak-filter-panel">
      <%= if length(@scopes) > 0 do %>
        <div class="ak-scopes">
          <%= for scope <- @scopes do %>
            <button
              phx-click="scope"
              phx-value-scope={scope.name}
              phx-target={@myself}
              class={"ak-scope-btn #{if @active_scope && @active_scope.name == scope.name, do: "ak-scope-active"}"}
            >
              <%= scope.label %>
            </button>
          <% end %>
        </div>
      <% end %>
    </div>
    """
  end

  @impl true
  def handle_event("scope", %{"scope" => scope_name}, socket) do
    send(self(), {:scope, scope_name})
    {:noreply, socket}
  end
end
