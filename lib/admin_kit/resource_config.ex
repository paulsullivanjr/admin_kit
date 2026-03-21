defmodule AdminKit.ResourceConfig do
  @moduledoc """
  Compiled configuration for a single admin resource.
  Built at compile time by the `AdminKit.Resource` DSL macro.
  """

  alias AdminKit.{Field, Action, Scope}

  @type t :: %__MODULE__{
          schema: module(),
          context: module(),
          singular_name: String.t(),
          plural_name: String.t(),
          fields: [Field.t()],
          index_fields: [atom()],
          form_fields: [atom()],
          actions: [Action.t()],
          scopes: [Scope.t()],
          searchable_fields: [atom()],
          per_page: pos_integer(),
          policy: module() | nil
        }

  defstruct [
    :schema,
    :context,
    :singular_name,
    :plural_name,
    fields: [],
    index_fields: [],
    form_fields: [],
    actions: [],
    scopes: [],
    searchable_fields: [],
    per_page: 25,
    policy: nil
  ]

  @doc "Returns field structs for the index view, in configured order."
  @spec index_fields(t()) :: [Field.t()]
  def index_fields(%__MODULE__{fields: fields, index_fields: names}) do
    fields
    |> Enum.filter(&(&1.name in names))
    |> Enum.sort_by(&Enum.find_index(names, fn n -> n == &1.name end))
  end

  @doc "Returns field structs for the form view."
  @spec form_fields(t()) :: [Field.t()]
  def form_fields(%__MODULE__{fields: fields, form_fields: names}) do
    fields
    |> Enum.filter(&(&1.name in names))
    |> Enum.sort_by(&Enum.find_index(names, fn n -> n == &1.name end))
  end

  @doc "Returns the default scope, or nil."
  @spec default_scope(t()) :: Scope.t() | nil
  def default_scope(%__MODULE__{scopes: scopes}), do: Enum.find(scopes, & &1.default)
end
