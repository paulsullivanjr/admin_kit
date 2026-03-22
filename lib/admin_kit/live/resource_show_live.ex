defmodule AdminKit.Live.ResourceShowLive do
  @moduledoc "Show LiveView for displaying a single resource with all visible fields."
  use Phoenix.LiveView

  alias AdminKit.{Context, Field, Live.Helpers}

  @impl true
  def mount(_params, session, socket) do
    config = Helpers.get_resource_config(socket, session)
    {:ok, assign(socket, config: config)}
  end

  @impl true
  def handle_params(%{"id" => id}, _uri, socket) do
    config = socket.assigns.config
    record = Context.get(config, id)

    {:noreply,
     assign(socket,
       record: record,
       page_title: "#{String.capitalize(config.singular_name)} ##{id}"
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="ak-resource-show">
      <div class="ak-header">
        <h1 class="ak-page-title"><%= @page_title %></h1>
        <div class="ak-header-actions">
          <.link navigate={"/#{@config.plural_name}/#{Map.get(@record, :id)}/edit"} class="ak-btn ak-btn-primary">
            Edit
          </.link>
          <.link navigate={"/#{@config.plural_name}"} class="ak-btn ak-btn-secondary">
            Back to list
          </.link>
        </div>
      </div>

      <!-- Actions -->
      <%= if length(@config.actions) > 0 do %>
        <div class="ak-actions-bar">
          <%= for action <- Enum.filter(@config.actions, & &1.scope == :member) do %>
            <button
              phx-click="action"
              phx-value-action={action.name}
              data-confirm={action.confirm}
              class="ak-btn ak-btn-sm"
            >
              <%= action.label %>
            </button>
          <% end %>
        </div>
      <% end %>

      <!-- Fields -->
      <dl class="ak-detail-list">
        <%= for field <- show_fields(@config) do %>
          <div class="ak-detail-row">
            <dt class="ak-detail-label"><%= Field.label(field) %></dt>
            <dd class="ak-detail-value">
              <%= render_field_show(Map.get(@record, field.name), field) %>
            </dd>
          </div>
        <% end %>
      </dl>
    </div>
    """
  end

  @impl true
  def handle_event("action", %{"action" => action_name}, socket) do
    config = socket.assigns.config
    action = Enum.find(config.actions, &(to_string(&1.name) == action_name))

    case action.handler.(socket.assigns.record) do
      {:ok, updated} ->
        {:noreply,
         socket
         |> assign(record: updated)
         |> put_flash(:info, "#{action.label} completed.")}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "#{action.label} failed.")}
    end
  end

  defp show_fields(config) do
    Enum.filter(config.fields, & &1.show_in_show)
  end

  defp render_field_show(value, field) do
    mod = AdminKit.field_type_module(field.type)
    mod.render_show(value, field)
  end

end
