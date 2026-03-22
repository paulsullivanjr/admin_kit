defmodule AdminKit.Live.Helpers do
  @moduledoc false
  # Shared helpers for AdminKit LiveViews.

  @doc "Resolves the resource config from socket metadata or session."
  def get_resource_config(socket, session) do
    resource_module =
      get_metadata(socket, session, :resource_module) ||
        raise "AdminKit: resource_module not found in socket or session"

    resource_module.__admin_config__()
  end

  @doc "Resolves the admin module from socket metadata or session."
  def get_admin_module(socket, session) do
    get_metadata(socket, session, :admin_module) ||
      raise "AdminKit: admin_module not found in socket or session"
  end

  defp get_metadata(socket, session, key) do
    case socket.private do
      %{connect_info: %{metadata: metadata}} -> Map.get(metadata, key)
      _ -> Map.get(session, to_string(key))
    end
  end
end
