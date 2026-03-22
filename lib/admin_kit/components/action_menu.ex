defmodule AdminKit.Components.ActionMenu do
  @moduledoc "Stateful action menu component for member and collection actions."
  use Phoenix.LiveComponent

  @impl true
  def render(assigns) do
    ~H"""
    <div class="ak-action-menu">
      <%= for action <- @actions do %>
        <button
          phx-click="run_action"
          phx-value-action={action.name}
          phx-target={@myself}
          data-confirm={action.confirm}
          class="ak-btn ak-btn-sm"
        >
          <%= action.label %>
        </button>
      <% end %>
    </div>
    """
  end

  @impl true
  def handle_event("run_action", %{"action" => action_name}, socket) do
    send(self(), {:run_action, action_name})
    {:noreply, socket}
  end
end
