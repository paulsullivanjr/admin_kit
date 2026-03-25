defmodule AdminKit.Components.DataTable do
  @moduledoc "Stateful data table component with sorting and row selection."
  use Phoenix.LiveComponent

  alias AdminKit.{Field, ResourceConfig}

  @impl true
  def render(assigns) do
    ~H"""
    <div class="ak-data-table">
      <table class="ak-table">
        <thead>
          <tr>
            <%= if @selectable do %>
              <th class="ak-th ak-th-checkbox">
                <input
                  type="checkbox"
                  phx-click="select_all"
                  phx-target={@myself}
                  checked={all_selected?(@selected_ids, @records)}
                />
              </th>
            <% end %>
            <%= for field <- ResourceConfig.index_fields(@config) do %>
              <th class="ak-th" phx-click="sort" phx-value-field={field.name} phx-target={@myself}>
                <%= Field.label(field) %>
                <%= if @sort_by == field.name do %>
                  <span class="ak-sort-indicator">
                    <%= if @sort_dir == :asc, do: "▲", else: "▼" %>
                  </span>
                <% end %>
              </th>
            <% end %>
            <th class="ak-th">Actions</th>
          </tr>
        </thead>
        <tbody>
          <%= for record <- @records do %>
            <tr class={"ak-tr #{if Map.get(record, :id) in @selected_ids, do: "ak-tr-selected"}"}>
              <%= if @selectable do %>
                <td class="ak-td">
                  <input
                    type="checkbox"
                    phx-click="select_row"
                    phx-value-id={Map.get(record, :id)}
                    phx-target={@myself}
                    checked={Map.get(record, :id) in @selected_ids}
                  />
                </td>
              <% end %>
              <%= for field <- ResourceConfig.index_fields(@config) do %>
                <td class="ak-td">
                  <%= render_field(Map.get(record, field.name), field) %>
                </td>
              <% end %>
              <td class="ak-td ak-actions">
                <.link
                  navigate={"/#{@config.plural_name}/#{Map.get(record, :id)}"}
                  class="ak-action-link"
                >
                  Show
                </.link>
                <.link
                  navigate={"/#{@config.plural_name}/#{Map.get(record, :id)}/edit"}
                  class="ak-action-link"
                >
                  Edit
                </.link>
                <button
                  phx-click="delete"
                  phx-value-id={Map.get(record, :id)}
                  data-confirm="Are you sure?"
                  class="ak-action-link ak-action-danger"
                >
                  Delete
                </button>
              </td>
            </tr>
          <% end %>
        </tbody>
      </table>
    </div>
    """
  end

  @impl true
  def handle_event("sort", %{"field" => field}, socket) do
    send(self(), {:sort, String.to_existing_atom(field)})
    {:noreply, socket}
  end

  def handle_event("select_row", %{"id" => id}, socket) do
    send(self(), {:select_row, String.to_integer(id)})
    {:noreply, socket}
  end

  def handle_event("select_all", _params, socket) do
    send(self(), :select_all)
    {:noreply, socket}
  end

  defp render_field(value, field) do
    mod = AdminKit.field_type_module(field.type)
    mod.render_index(value, field)
  end

  defp all_selected?(selected, records) do
    ids = MapSet.new(records, &Map.get(&1, :id))
    MapSet.size(ids) > 0 and MapSet.equal?(selected, ids)
  end
end
