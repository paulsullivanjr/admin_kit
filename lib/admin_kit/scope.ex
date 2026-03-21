defmodule AdminKit.Scope do
  @moduledoc "Represents a named filter scope on a resource."

  @type t :: %__MODULE__{
          name: atom(),
          label: String.t(),
          filter: (Ecto.Query.t() -> Ecto.Query.t()),
          default: boolean()
        }

  defstruct [:name, :label, :filter, default: false]
end
