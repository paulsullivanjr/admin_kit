defmodule AdminKit.Components.PaginationBar do
  @moduledoc "Stateful pagination bar component."
  use Phoenix.LiveComponent

  @impl true
  def render(assigns) do
    ~H"""
    <%= if @total_pages > 1 do %>
      <nav class="ak-pagination" aria-label="Pagination">
        <button phx-click="page" phx-value-page={@page - 1} phx-target={@myself} disabled={@page <= 1} class="ak-btn ak-btn-sm">
          &laquo; Prev
        </button>
        <span class="ak-pagination-info">
          Page <%= @page %> of <%= @total_pages %> (<%= @total_count %> total)
        </span>
        <button phx-click="page" phx-value-page={@page + 1} phx-target={@myself} disabled={@page >= @total_pages} class="ak-btn ak-btn-sm">
          Next &raquo;
        </button>
      </nav>
    <% end %>
    """
  end

  @impl true
  def handle_event("page", %{"page" => page}, socket) do
    send(self(), {:page, String.to_integer(page)})
    {:noreply, socket}
  end
end
