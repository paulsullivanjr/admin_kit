defmodule AdminKit.Resource do
  @moduledoc """
  Behaviour and DSL macro for defining admin resources.

  ## Usage

      defmodule MyApp.Admin.UserResource do
        use AdminKit.Resource

        resource MyApp.Accounts.User do
          context MyApp.Accounts
          index_fields [:name, :email, :role, :inserted_at]
          form_fields  [:name, :email, :role]
          field :role, type: :select, choices: [:admin, :editor, :viewer]
          scope :all, default: true
          scope :admins, filter: fn q -> where(q, role: :admin) end
          action :confirm, label: "Confirm email", handler: &MyApp.Accounts.confirm_user/1
          searchable_fields [:name, :email]
          per_page 50
        end
      end
  """

  @callback list(params :: map()) :: [struct()]
  @callback get(id :: any()) :: struct() | nil
  @callback new_changeset(attrs :: map()) :: Ecto.Changeset.t()
  @callback edit_changeset(struct(), attrs :: map()) :: Ecto.Changeset.t()
  @callback create(attrs :: map()) :: {:ok, struct()} | {:error, Ecto.Changeset.t()}
  @callback update(struct(), attrs :: map()) :: {:ok, struct()} | {:error, Ecto.Changeset.t()}
  @callback delete(struct()) :: {:ok, struct()} | {:error, any()}

  @optional_callbacks [
    list: 1,
    get: 1,
    new_changeset: 1,
    edit_changeset: 2,
    create: 1,
    update: 2,
    delete: 1
  ]

  defmacro __using__(_opts) do
    quote do
      import AdminKit.Resource, only: [resource: 2]
      @behaviour AdminKit.Resource
      Module.register_attribute(__MODULE__, :admin_resource_config, persist: true)
    end
  end

  defmacro resource(schema, do: block) do
    quote do
      Module.register_attribute(__MODULE__, :ak_context, accumulate: false)
      Module.register_attribute(__MODULE__, :ak_fields, accumulate: true)
      Module.register_attribute(__MODULE__, :ak_index_fields, accumulate: false)
      Module.register_attribute(__MODULE__, :ak_form_fields, accumulate: false)
      Module.register_attribute(__MODULE__, :ak_actions, accumulate: true)
      Module.register_attribute(__MODULE__, :ak_scopes, accumulate: true)
      Module.register_attribute(__MODULE__, :ak_searchable, accumulate: false)
      Module.register_attribute(__MODULE__, :ak_per_page, accumulate: false)
      Module.register_attribute(__MODULE__, :ak_policy, accumulate: false)

      import AdminKit.Resource.DSL
      unquote(block)

      @admin_resource_config AdminKit.Resource.Compiler.compile(
                               unquote(schema),
                               @ak_context,
                               @ak_fields || [],
                               @ak_index_fields || [],
                               @ak_form_fields || [],
                               @ak_actions || [],
                               @ak_scopes || [],
                               @ak_searchable || [],
                               @ak_per_page || 25,
                               @ak_policy
                             )

      @doc false
      def __admin_config__, do: @admin_resource_config
    end
  end
end
