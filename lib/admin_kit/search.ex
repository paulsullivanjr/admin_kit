defmodule AdminKit.Search do
  @moduledoc "Builds dynamic Ecto queries for search and filtering."
  import Ecto.Query

  @doc "Applies a search query string across all searchable fields (OR match)."
  @spec apply_search(Ecto.Query.t(), String.t() | nil, [atom()]) :: Ecto.Query.t()
  def apply_search(query, nil, _fields), do: query
  def apply_search(query, "", _fields), do: query

  def apply_search(query, search, fields) do
    term = "%#{search}%"

    conditions =
      Enum.reduce(fields, false, fn field, acc ->
        dynamic([r], ilike(field(r, ^field), ^term) or ^acc)
      end)

    where(query, ^conditions)
  end

  @doc "Applies sorting."
  @spec apply_sort(Ecto.Query.t(), atom(), :asc | :desc) :: Ecto.Query.t()
  def apply_sort(query, field, direction) do
    order_by(query, [{^direction, ^field}])
  end

  @doc "Applies a scope filter."
  @spec apply_scope(Ecto.Query.t(), AdminKit.Scope.t() | nil) :: Ecto.Query.t()
  def apply_scope(query, nil), do: query
  def apply_scope(query, %{filter: filter}), do: filter.(query)
end
