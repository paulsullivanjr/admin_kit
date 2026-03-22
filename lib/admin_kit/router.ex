defmodule AdminKit.Router do
  @moduledoc """
  Provides the `live_admin/3` macro for Phoenix routers.

  ## Usage

      # In your Phoenix router:
      import AdminKit.Router

      scope "/admin" do
        pipe_through [:browser, :require_admin_user]
        live_admin "/", MyApp.Admin
      end

  This generates the following routes for each registered resource:

      GET  /admin                        -> Dashboard
      GET  /admin/:resource              -> Index
      GET  /admin/:resource/new          -> New form
      GET  /admin/:resource/:id          -> Show
      GET  /admin/:resource/:id/edit     -> Edit form
  """

  defmacro live_admin(path, admin_module, opts \\ []) do
    quote bind_quoted: [path: path, admin_module: admin_module, opts: opts] do
      scope path, alias: false do
        import Phoenix.LiveView.Router, only: [live: 4]

        live "/", AdminKit.Live.DashboardLive, :index,
          as: :admin_kit_dashboard,
          metadata: %{admin_module: admin_module}

        # Use resource names (atoms/strings) at compile time, not full configs.
        # LiveViews look up the full config at runtime via admin_module.
        for {plural_name, resource_module} <- admin_module.__resource_index__() do
          resource_path = "/#{plural_name}"

          live resource_path, AdminKit.Live.ResourceIndexLive, :index,
            as: :"admin_kit_#{plural_name}",
            metadata: %{admin_module: admin_module, resource_module: resource_module}

          live "#{resource_path}/new", AdminKit.Live.ResourceFormLive, :new,
            as: :"admin_kit_#{plural_name}_new",
            metadata: %{admin_module: admin_module, resource_module: resource_module}

          live "#{resource_path}/:id", AdminKit.Live.ResourceShowLive, :show,
            as: :"admin_kit_#{plural_name}_show",
            metadata: %{admin_module: admin_module, resource_module: resource_module}

          live "#{resource_path}/:id/edit", AdminKit.Live.ResourceFormLive, :edit,
            as: :"admin_kit_#{plural_name}_edit",
            metadata: %{admin_module: admin_module, resource_module: resource_module}
        end
      end
    end
  end
end
