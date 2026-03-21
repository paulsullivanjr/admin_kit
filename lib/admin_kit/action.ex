defmodule AdminKit.Action do
  @moduledoc "Represents a custom action (beyond CRUD) on a resource."

  @type scope :: :member | :collection
  @type t :: %__MODULE__{
          name: atom(),
          label: String.t(),
          handler: (struct() -> {:ok, any()} | {:error, any()}),
          scope: scope(),
          icon: atom() | nil,
          confirm: String.t() | nil,
          policy: atom() | nil
        }

  defstruct [
    :name,
    :label,
    :handler,
    :icon,
    :confirm,
    :policy,
    scope: :member
  ]
end
