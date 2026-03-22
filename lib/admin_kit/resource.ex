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

      # Capture raw DSL values at compile time to use in the runtime function.
      # We can't store anonymous functions in module attributes, so we build
      # the config struct at runtime on first call instead.
      @_ak_schema unquote(schema)
      @_ak_ctx @ak_context
      @_ak_raw_fields @ak_fields || []
      @_ak_idx_fields @ak_index_fields || []
      @_ak_frm_fields @ak_form_fields || []
      @_ak_raw_actions @ak_actions || []
      @_ak_raw_scopes @ak_scopes || []
      @_ak_searchable @ak_searchable || []
      @_ak_pp @ak_per_page || 25
      @_ak_pol @ak_policy

      # Validate at compile time (non-function checks)
      AdminKit.Resource.Compiler.validate_compile_time!(@_ak_schema, @_ak_ctx)

      @doc false
      def __admin_config__ do
        AdminKit.Resource.Compiler.compile(
          @_ak_schema,
          @_ak_ctx,
          @_ak_raw_fields,
          @_ak_idx_fields,
          @_ak_frm_fields,
          @_ak_raw_actions,
          @_ak_raw_scopes,
          @_ak_searchable,
          @_ak_pp,
          @_ak_pol,
          __MODULE__
        )
      end
    end
  end
end
