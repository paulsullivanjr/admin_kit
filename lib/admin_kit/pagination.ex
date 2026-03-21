defmodule AdminKit.Pagination do
  @moduledoc "Offset-based pagination helpers."

  @type t :: %__MODULE__{
          page: pos_integer(),
          per_page: pos_integer(),
          total_count: non_neg_integer(),
          total_pages: pos_integer()
        }

  defstruct [:page, :per_page, :total_count, :total_pages]

  @doc "Builds a pagination struct from total count and params."
  @spec build(non_neg_integer(), map(), pos_integer()) :: t()
  def build(total_count, params, per_page) do
    page = max(String.to_integer(Map.get(params, "page", "1")), 1)
    total_pages = max(ceil(total_count / per_page), 1)

    %__MODULE__{
      page: min(page, total_pages),
      per_page: per_page,
      total_count: total_count,
      total_pages: total_pages
    }
  end

  @doc "Returns an Ecto query with LIMIT/OFFSET applied."
  @spec paginate(Ecto.Query.t(), t()) :: Ecto.Query.t()
  def paginate(query, %__MODULE__{page: page, per_page: per_page}) do
    import Ecto.Query
    offset = (page - 1) * per_page
    query |> limit(^per_page) |> offset(^offset)
  end

  @doc "Returns true if there is a previous page."
  @spec has_prev?(t()) :: boolean()
  def has_prev?(%__MODULE__{page: page}), do: page > 1

  @doc "Returns true if there is a next page."
  @spec has_next?(t()) :: boolean()
  def has_next?(%__MODULE__{page: page, total_pages: total}), do: page < total
end
