defmodule AdminKit.HTML.CoreComponents do
  @moduledoc "Shared HEEX function components used across AdminKit views."
  use Phoenix.Component

  @doc "Renders a flash message group."
  attr :flash, :map, required: true

  def flash_group(assigns) do
    ~H"""
    <div class="ak-flash-group">
      <%= if msg = Phoenix.Flash.get(@flash, :info) do %>
        <div
          class="ak-flash ak-flash-info"
          role="alert"
          phx-click="lv:clear-flash"
          phx-value-key="info"
        >
          <%= msg %>
        </div>
      <% end %>
      <%= if msg = Phoenix.Flash.get(@flash, :error) do %>
        <div
          class="ak-flash ak-flash-error"
          role="alert"
          phx-click="lv:clear-flash"
          phx-value-key="error"
        >
          <%= msg %>
        </div>
      <% end %>
    </div>
    """
  end

  @doc "Renders breadcrumb navigation."
  attr :items, :list, required: true

  def breadcrumbs(assigns) do
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

  @doc "Renders an action menu with dropdown items."
  attr :actions, :list, required: true
  attr :record, :map, default: nil

  def action_menu(assigns) do
    ~H"""
    <div class="ak-action-menu">
      <%= for action <- @actions do %>
        <button
          phx-click="action"
          phx-value-action={action.name}
          phx-value-id={if @record, do: Map.get(@record, :id)}
          data-confirm={action.confirm}
          class="ak-action-menu-item"
        >
          <%= action.label %>
        </button>
      <% end %>
    </div>
    """
  end

  @doc "Renders a pagination bar."
  attr :page, :integer, required: true
  attr :total_pages, :integer, required: true
  attr :total_count, :integer, required: true

  def pagination_bar(assigns) do
    ~H"""
    <%= if @total_pages > 1 do %>
      <nav class="ak-pagination" aria-label="Pagination">
        <button
          phx-click="page"
          phx-value-page={@page - 1}
          disabled={@page <= 1}
          class="ak-btn ak-btn-sm"
        >
          &laquo; Prev
        </button>
        <span class="ak-pagination-info">
          Page <%= @page %> of <%= @total_pages %> (<%= @total_count %> total)
        </span>
        <button
          phx-click="page"
          phx-value-page={@page + 1}
          disabled={@page >= @total_pages}
          class="ak-btn ak-btn-sm"
        >
          Next &raquo;
        </button>
      </nav>
    <% end %>
    """
  end

  @doc "Renders a search bar input."
  attr :query, :string, default: ""
  attr :placeholder, :string, default: "Search..."

  def search_bar(assigns) do
    ~H"""
    <form phx-change="search" phx-submit="search" class="ak-search-form">
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

  @doc "Renders sidebar navigation with resource links."
  attr :resources, :list, required: true
  attr :current_resource, :string, default: nil

  def sidebar_nav(assigns) do
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
