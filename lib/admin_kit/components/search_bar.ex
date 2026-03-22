defmodule AdminKit.Components.SearchBar do
  @moduledoc "Stateful search bar component with debounced input."
  use Phoenix.LiveComponent

  @impl true
  def render(assigns) do
    ~H"""
    <form phx-change="search" phx-submit="search" phx-target={@myself} class="ak-search-form">
      <input
        type="text"
        name="query"
        value={@query}
        placeholder={@placeholder}
        class="ak-input ak-search-input"
        phx-debounce="300"
      />
    </form>
    """
  end

  @impl true
  def handle_event("search", %{"query" => query}, socket) do
    send(self(), {:search, query})
    {:noreply, socket}
  end
end
