defmodule AdminKit.Policy do
  @moduledoc """
  Behaviour for plugging in authorization into AdminKit.

  Implement this module and reference it in your resource config
  via `policy MyApp.Admin.MyPolicy`.

  ## Example

      defmodule MyApp.Admin.UserPolicy do
        @behaviour AdminKit.Policy

        @impl true
        def can?(conn_or_socket, :index, _resource), do: true
        def can?(%{assigns: %{current_user: user}}, :delete, _resource), do: user.role == :super_admin
        def can?(_, _, _), do: false
      end
  """

  @type action :: :index | :show | :new | :create | :edit | :update | :delete | atom()

  @doc """
  Returns `true` if the current user (from conn or socket assigns) may perform
  `action` on `resource` (the ResourceConfig struct).
  """
  @callback can?(
              conn_or_socket :: any(),
              action :: action(),
              resource :: AdminKit.ResourceConfig.t()
            ) :: boolean()

  @doc "Default permissive policy — allows everything. Use only in development."
  def allow_all, do: AdminKit.Policy.AllowAll

  defmodule AllowAll do
    @moduledoc "Permissive policy that allows all actions. Use only in development."
    @behaviour AdminKit.Policy
    @impl true
    def can?(_, _, _), do: true
  end
end
