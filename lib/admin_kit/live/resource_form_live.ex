defmodule AdminKit.Live.ResourceFormLive do
  @moduledoc "New/Edit LiveView for creating and updating resources."
  use Phoenix.LiveView

  alias AdminKit.{Context, ResourceConfig}

  @impl true
  def mount(_params, session, socket) do
    config = get_resource_config(socket, session)
    {:ok, assign(socket, config: config)}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    config = socket.assigns.config
    record = struct(config.schema)
    changeset = Context.change(config, record)

    assign(socket,
      record: record,
      changeset: changeset,
      form: to_form(changeset),
      page_title: "New #{String.capitalize(config.singular_name)}"
    )
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    config = socket.assigns.config
    record = Context.get(config, id)
    changeset = Context.change(config, record)

    assign(socket,
      record: record,
      changeset: changeset,
      form: to_form(changeset),
      page_title: "Edit #{String.capitalize(config.singular_name)}"
    )
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="ak-resource-form">
      <h1 class="ak-page-title"><%= @page_title %></h1>

      <.form for={@form} phx-change="validate" phx-submit="save" class="ak-form">
        <%= for field <- ResourceConfig.form_fields(@config) do %>
          <div class="ak-form-group">
            <label class="ak-label" for={field.name}><%= AdminKit.Field.label(field) %></label>
            <%= render_field_form(@form, field) %>
            <%= if error = get_error(@form, field.name) do %>
              <span class="ak-error"><%= error %></span>
            <% end %>
          </div>
        <% end %>

        <div class="ak-form-actions">
          <button type="submit" class="ak-btn ak-btn-primary">
            <%= if @live_action == :new, do: "Create", else: "Update" %>
          </button>
          <.link navigate={"/#{@config.plural_name}"} class="ak-btn ak-btn-secondary">
            Cancel
          </.link>
        </div>
      </.form>
    </div>
    """
  end

  @impl true
  def handle_event("validate", %{} = params, socket) do
    config = socket.assigns.config
    param_key = config.singular_name
    attrs = Map.get(params, param_key, %{})

    changeset =
      Context.change(config, socket.assigns.record, attrs)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, changeset: changeset, form: to_form(changeset))}
  end

  def handle_event("save", %{} = params, socket) do
    config = socket.assigns.config
    param_key = config.singular_name
    attrs = Map.get(params, param_key, %{})

    save(socket, socket.assigns.live_action, attrs)
  end

  defp save(socket, :new, attrs) do
    config = socket.assigns.config

    case Context.create(config, attrs) do
      {:ok, record} ->
        {:noreply,
         socket
         |> put_flash(:info, "#{String.capitalize(config.singular_name)} created.")
         |> push_navigate(to: "/#{config.plural_name}/#{Map.get(record, :id)}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset, form: to_form(changeset))}
    end
  end

  defp save(socket, :edit, attrs) do
    config = socket.assigns.config

    case Context.update(config, socket.assigns.record, attrs) do
      {:ok, record} ->
        {:noreply,
         socket
         |> put_flash(:info, "#{String.capitalize(config.singular_name)} updated.")
         |> push_navigate(to: "/#{config.plural_name}/#{Map.get(record, :id)}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset, form: to_form(changeset))}
    end
  end

  defp render_field_form(form, field) do
    mod = AdminKit.field_type_module(field.type)
    mod.render_form(form, field, [])
  end

  defp get_error(form, field_name) do
    case form.errors[field_name] do
      {msg, _opts} -> msg
      _ -> nil
    end
  end

  defp get_resource_config(socket, session) do
    case socket.private[:connect_info] do
      %{metadata: %{resource: config}} -> config
      _ -> Map.get(session, "resource") || raise "AdminKit: resource config not found"
    end
  end
end
