defmodule AdminKit do
  @moduledoc """
  AdminKit — DDD-first LiveView admin interface for Phoenix.

  ## Setup

  1. Add to your `mix.exs` deps: `{:admin_kit, "~> 0.1"}`
  2. Create an admin module:

         defmodule MyApp.Admin do
           use AdminKit, otp_app: :my_app

           admin_resource MyApp.Accounts.User do
             context MyApp.Accounts
             index_fields [:name, :email, :role]
             form_fields  [:name, :email]
             scope :all, default: true
             searchable_fields [:name, :email]
           end
         end

  3. Add to your router:

         import AdminKit.Router
         live_admin "/admin", MyApp.Admin

  4. Add to your `endpoint.ex`:

         plug Plug.Static, at: "/admin_kit", from: {:admin_kit, "priv/static"}
  """

  defmacro __using__(opts) do
    quote do
      import AdminKit, only: [admin_resource: 2]
      @admin_kit_otp_app Keyword.fetch!(unquote(opts), :otp_app)
      Module.register_attribute(__MODULE__, :admin_resources, accumulate: true)

      @before_compile AdminKit
    end
  end

  defmacro admin_resource(schema, do: block) do
    quote do
      defmodule :"#{__MODULE__}.#{unquote(schema) |> Module.split() |> List.last()}Resource" do
        use AdminKit.Resource

        resource unquote(schema) do
          unquote(block)
        end
      end

      @admin_resources __MODULE__
                       |> Module.concat(
                         unquote(schema)
                         |> Module.split()
                         |> List.last()
                         |> Kernel.<>("Resource")
                       )
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      @doc false
      def __resources__ do
        @admin_resources
        |> Enum.map(& &1.__admin_config__())
      end

      @doc false
      # Compile-safe index of {plural_name, resource_module} tuples.
      # Used by the router macro — no anonymous functions, just atoms.
      def __resource_index__ do
        @admin_resources
        |> Enum.map(fn mod ->
          config = mod.__admin_config__()
          {config.plural_name, mod}
        end)
      end
    end
  end

  @doc "Register a custom field type at runtime."
  @spec register_field_type(atom(), module()) :: :ok
  def register_field_type(type_name, module) do
    current = Application.get_env(:admin_kit, :custom_field_types, %{})
    Application.put_env(:admin_kit, :custom_field_types, Map.put(current, type_name, module))
    :ok
  end

  @doc "Resolve a field type module by atom name."
  @spec field_type_module(atom()) :: module()
  def field_type_module(type) do
    custom = Application.get_env(:admin_kit, :custom_field_types, %{})
    Map.get(custom, type) || Map.fetch!(default_field_types(), type)
  end

  defp default_field_types do
    %{
      string: AdminKit.FieldTypes.String,
      integer: AdminKit.FieldTypes.Integer,
      boolean: AdminKit.FieldTypes.Boolean,
      datetime: AdminKit.FieldTypes.Datetime,
      date: AdminKit.FieldTypes.Date,
      select: AdminKit.FieldTypes.Select,
      multi_select: AdminKit.FieldTypes.MultiSelect,
      image: AdminKit.FieldTypes.Image,
      rich_text: AdminKit.FieldTypes.RichText,
      json_viewer: AdminKit.FieldTypes.JsonViewer,
      belongs_to: AdminKit.FieldTypes.BelongsTo,
      has_many: AdminKit.FieldTypes.HasMany
    }
  end
end
