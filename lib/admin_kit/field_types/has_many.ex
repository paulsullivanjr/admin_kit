defmodule AdminKit.FieldTypes.HasMany do
  @moduledoc "Has-many association field type. Count badge in index; linked list in show."
  @behaviour AdminKit.FieldType
  use Phoenix.Component

  @impl true
  def render_index(nil, _field) do
    assigns = %{}
    ~H|<span class="ak-badge">0</span>|
  end

  def render_index(%Ecto.Association.NotLoaded{}, _field) do
    assigns = %{}
    ~H|<span class="ak-text-muted">—</span>|
  end

  def render_index(values, _field) when is_list(values) do
    assigns = %{count: length(values)}
    ~H|<span class="ak-badge"><%= @count %></span>|
  end

  def render_index(_value, _field) do
    assigns = %{}
    ~H|<span class="ak-text-muted">—</span>|
  end

  @impl true
  def render_show(nil, _field) do
    assigns = %{}
    ~H|<span class="ak-text-muted">None</span>|
  end

  def render_show(%Ecto.Association.NotLoaded{}, _field) do
    assigns = %{}
    ~H|<span class="ak-text-muted">Not loaded</span>|
  end

  def render_show(values, _field) when is_list(values) do
    items = Enum.map(values, &display_name/1)
    assigns = %{items: items}

    ~H"""
    <ul class="ak-list">
      <%= for item <- @items do %>
        <li><%= item %></li>
      <% end %>
    </ul>
    """
  end

  def render_show(_value, _field) do
    assigns = %{}
    ~H|<span class="ak-text-muted">—</span>|
  end

  @impl true
  def render_form(_form, _field, _opts) do
    assigns = %{}
    ~H|<span class="ak-text-muted">Managed via associated resource</span>|
  end

  defp display_name(%{name: name}), do: name
  defp display_name(%{title: title}), do: title
  defp display_name(%{id: id}), do: "##{id}"
  defp display_name(value), do: to_string(value)
end
