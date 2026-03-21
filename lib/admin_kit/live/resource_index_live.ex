defmodule AdminKit.Live.ResourceIndexLive do
  @moduledoc "Index LiveView for listing, searching, sorting, and paginating resources."
  use Phoenix.LiveView

  alias AdminKit.{Context, ResourceConfig}

  @impl true
  def mount(_params, session, socket) do
    config = get_resource_config(socket, session)

    {:ok,
     assign(socket,
       config: config,
       resources: [],
       search_query: "",
       sort_by: List.first(config.index_fields),
       sort_dir: :asc,
       page: 1,
       total_count: 0,
       total_pages: 1,
       selected_ids: MapSet.new(),
       active_scope: ResourceConfig.default_scope(config),
       page_title: String.capitalize(config.plural_name)
     )}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    socket =
      socket
      |> apply_params(params)
      |> load_resources()

    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="ak-resource-index">
      <div class="ak-header">
        <h1 class="ak-page-title"><%= String.capitalize(@config.plural_name) %></h1>
        <.link navigate={"/#{@config.plural_name}/new"} class="ak-btn ak-btn-primary">
          New <%= String.capitalize(@config.singular_name) %>
        </.link>
      </div>

      <!-- Scopes -->
      <%= if length(@config.scopes) > 0 do %>
        <div class="ak-scopes">
          <%= for scope <- @config.scopes do %>
            <button
              phx-click="scope"
              phx-value-scope={scope.name}
              class={"ak-scope-btn #{if @active_scope && @active_scope.name == scope.name, do: "ak-scope-active"}"}
            >
              <%= scope.label %>
            </button>
          <% end %>
        </div>
      <% end %>

      <!-- Search -->
      <%= if length(@config.searchable_fields) > 0 do %>
        <form phx-change="search" phx-submit="search" class="ak-search-form">
          <input
            type="text"
            name="query"
            value={@search_query}
            placeholder={"Search #{@config.plural_name}..."}
            class="ak-input ak-search-input"
            phx-debounce="300"
          />
        </form>
      <% end %>

      <!-- Data Table -->
      <table class="ak-table">
        <thead>
          <tr>
            <th class="ak-th ak-th-checkbox">
              <input type="checkbox" phx-click="select_all" checked={all_selected?(@selected_ids, @resources)} />
            </th>
            <%= for field <- ResourceConfig.index_fields(@config) do %>
              <th class="ak-th" phx-click="sort" phx-value-field={field.name}>
                <%= AdminKit.Field.label(field) %>
                <%= if @sort_by == field.name do %>
                  <span class="ak-sort-indicator"><%= if @sort_dir == :asc, do: "▲", else: "▼" %></span>
                <% end %>
              </th>
            <% end %>
            <th class="ak-th">Actions</th>
          </tr>
        </thead>
        <tbody>
          <%= for record <- @resources do %>
            <tr class={"ak-tr #{if Map.get(record, :id) in @selected_ids, do: "ak-tr-selected"}"}>
              <td class="ak-td">
                <input type="checkbox" phx-click="select_row" phx-value-id={Map.get(record, :id)} checked={Map.get(record, :id) in @selected_ids} />
              </td>
              <%= for field <- ResourceConfig.index_fields(@config) do %>
                <td class="ak-td">
                  <%= render_field_index(Map.get(record, field.name), field) %>
                </td>
              <% end %>
              <td class="ak-td ak-actions">
                <.link navigate={"/#{@config.plural_name}/#{Map.get(record, :id)}"} class="ak-action-link">
                  Show
                </.link>
                <.link navigate={"/#{@config.plural_name}/#{Map.get(record, :id)}/edit"} class="ak-action-link">
                  Edit
                </.link>
                <button phx-click="delete" phx-value-id={Map.get(record, :id)} data-confirm="Are you sure?" class="ak-action-link ak-action-danger">
                  Delete
                </button>
              </td>
            </tr>
          <% end %>
        </tbody>
      </table>

      <!-- Pagination -->
      <%= if @total_pages > 1 do %>
        <div class="ak-pagination">
          <button phx-click="page" phx-value-page={@page - 1} disabled={@page <= 1} class="ak-btn ak-btn-sm">
            &laquo; Prev
          </button>
          <span class="ak-pagination-info">
            Page <%= @page %> of <%= @total_pages %> (<%= @total_count %> total)
          </span>
          <button phx-click="page" phx-value-page={@page + 1} disabled={@page >= @total_pages} class="ak-btn ak-btn-sm">
            Next &raquo;
          </button>
        </div>
      <% end %>
    </div>
    """
  end

  @impl true
  def handle_event("search", %{"query" => query}, socket) do
    {:noreply, socket |> assign(search_query: query, page: 1) |> load_resources()}
  end

  def handle_event("sort", %{"field" => field}, socket) do
    field = String.to_existing_atom(field)

    {sort_by, sort_dir} =
      if socket.assigns.sort_by == field do
        {field, toggle_dir(socket.assigns.sort_dir)}
      else
        {field, :asc}
      end

    {:noreply, socket |> assign(sort_by: sort_by, sort_dir: sort_dir) |> load_resources()}
  end

  def handle_event("scope", %{"scope" => scope_name}, socket) do
    scope = Enum.find(socket.assigns.config.scopes, &(to_string(&1.name) == scope_name))
    {:noreply, socket |> assign(active_scope: scope, page: 1) |> load_resources()}
  end

  def handle_event("select_row", %{"id" => id}, socket) do
    id = String.to_integer(id)
    selected = socket.assigns.selected_ids

    selected =
      if id in selected,
        do: MapSet.delete(selected, id),
        else: MapSet.put(selected, id)

    {:noreply, assign(socket, selected_ids: selected)}
  end

  def handle_event("select_all", _params, socket) do
    all_ids = MapSet.new(socket.assigns.resources, &Map.get(&1, :id))

    selected =
      if MapSet.equal?(socket.assigns.selected_ids, all_ids),
        do: MapSet.new(),
        else: all_ids

    {:noreply, assign(socket, selected_ids: selected)}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    config = socket.assigns.config
    record = Context.get(config, id)

    case Context.delete(config, record) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "#{String.capitalize(config.singular_name)} deleted.")
         |> load_resources()}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to delete.")}
    end
  end

  def handle_event("page", %{"page" => page}, socket) do
    page = String.to_integer(page)
    {:noreply, socket |> assign(page: page) |> load_resources()}
  end

  defp apply_params(socket, params) do
    assign(socket,
      page: String.to_integer(Map.get(params, "page", "1")),
      search_query: Map.get(params, "q", socket.assigns.search_query)
    )
  end

  defp load_resources(socket) do
    config = socket.assigns.config

    params = %{
      "page" => to_string(socket.assigns.page),
      "per_page" => to_string(config.per_page),
      "sort_by" => to_string(socket.assigns.sort_by),
      "sort_dir" => to_string(socket.assigns.sort_dir),
      "search" => socket.assigns.search_query
    }

    resources = Context.list(config, params)

    assign(socket,
      resources: resources,
      total_count: length(resources),
      total_pages: max(ceil(length(resources) / config.per_page), 1)
    )
  end

  defp render_field_index(value, field) do
    mod = AdminKit.field_type_module(field.type)
    mod.render_index(value, field)
  end

  defp toggle_dir(:asc), do: :desc
  defp toggle_dir(:desc), do: :asc

  defp all_selected?(selected, resources) do
    ids = MapSet.new(resources, &Map.get(&1, :id))
    MapSet.size(ids) > 0 and MapSet.equal?(selected, ids)
  end

  defp get_resource_config(socket, session) do
    case socket.private[:connect_info] do
      %{metadata: %{resource: config}} -> config
      _ -> Map.get(session, "resource") || raise "AdminKit: resource config not found"
    end
  end
end
