defmodule AdminKit.Field do
  @moduledoc """
  Represents a single configured field on a resource.
  """

  @type t :: %__MODULE__{
          name: atom(),
          type: atom(),
          label: String.t() | nil,
          opts: keyword(),
          show_in_index: boolean(),
          show_in_show: boolean(),
          show_in_form: boolean(),
          readonly: boolean(),
          sortable: boolean(),
          searchable: boolean()
        }

  defstruct [
    :name,
    :type,
    :label,
    opts: [],
    show_in_index: true,
    show_in_show: true,
    show_in_form: true,
    readonly: false,
    sortable: true,
    searchable: false
  ]

  @doc "Returns a human-readable label for the field, defaulting to the field name."
  @spec label(t()) :: String.t()
  def label(%__MODULE__{label: nil, name: name}) do
    name |> to_string() |> String.replace("_", " ") |> String.capitalize()
  end

  def label(%__MODULE__{label: label}), do: label
end
