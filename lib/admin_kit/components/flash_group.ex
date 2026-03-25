defmodule AdminKit.Components.FlashGroup do
  @moduledoc "Stateful flash message group component."
  use Phoenix.LiveComponent

  @impl true
  def render(assigns) do
    ~H"""
    <div class="ak-flash-group">
      <%= if msg = Phoenix.Flash.get(@flash, :info) do %>
        <div
          class="ak-flash ak-flash-info"
          role="alert"
          phx-click="dismiss"
          phx-value-key="info"
          phx-target={@myself}
        >
          <%= msg %>
        </div>
      <% end %>
      <%= if msg = Phoenix.Flash.get(@flash, :error) do %>
        <div
          class="ak-flash ak-flash-error"
          role="alert"
          phx-click="dismiss"
          phx-value-key="error"
          phx-target={@myself}
        >
          <%= msg %>
        </div>
      <% end %>
    </div>
    """
  end

  @impl true
  def handle_event("dismiss", %{"key" => key}, socket) do
    send(self(), {:clear_flash, key})
    {:noreply, socket}
  end
end
