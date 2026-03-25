defmodule AdminKit.Context do
  @moduledoc """
  Delegates data operations to the user's context module.
  Discovers functions by convention; raises clearly if they are missing.
  """

  alias AdminKit.ResourceConfig

  @spec list(ResourceConfig.t(), map()) :: [struct()]
  def list(%ResourceConfig{context: ctx} = config, params) do
    fn_name = :"list_#{config.plural_name}"

    cond do
      has_function?(ctx, fn_name, 1) ->
        apply(ctx, fn_name, [params])

      has_function?(ctx, fn_name, 0) ->
        apply(ctx, fn_name, [])

      true ->
        raise_missing(
          ctx,
          fn_name,
          "list_#{config.plural_name}(params) or list_#{config.plural_name}()"
        )
    end
  end

  @spec get(ResourceConfig.t(), any()) :: struct() | nil
  def get(%ResourceConfig{context: ctx} = config, id) do
    fn_name = :"get_#{config.singular_name}!"

    unless has_function?(ctx, fn_name, 1) do
      raise_missing(ctx, fn_name, "get_#{config.singular_name}!(id)")
    end

    apply(ctx, fn_name, [id])
  end

  @spec create(ResourceConfig.t(), map()) :: {:ok, struct()} | {:error, Ecto.Changeset.t()}
  def create(%ResourceConfig{context: ctx} = config, attrs) do
    fn_name = :"create_#{config.singular_name}"

    unless has_function?(ctx, fn_name, 1) do
      raise_missing(ctx, fn_name, "create_#{config.singular_name}(attrs)")
    end

    apply(ctx, fn_name, [attrs])
  end

  @spec update(ResourceConfig.t(), struct(), map()) ::
          {:ok, struct()} | {:error, Ecto.Changeset.t()}
  def update(%ResourceConfig{context: ctx} = config, record, attrs) do
    fn_name = :"update_#{config.singular_name}"

    unless has_function?(ctx, fn_name, 2) do
      raise_missing(ctx, fn_name, "update_#{config.singular_name}(record, attrs)")
    end

    apply(ctx, fn_name, [record, attrs])
  end

  @spec delete(ResourceConfig.t(), struct()) :: {:ok, struct()} | {:error, any()}
  def delete(%ResourceConfig{context: ctx} = config, record) do
    fn_name = :"delete_#{config.singular_name}"

    unless has_function?(ctx, fn_name, 1) do
      raise_missing(ctx, fn_name, "delete_#{config.singular_name}(record)")
    end

    apply(ctx, fn_name, [record])
  end

  @doc "Returns a new changeset for the resource."
  @spec change(ResourceConfig.t(), struct(), map()) :: Ecto.Changeset.t()
  def change(%ResourceConfig{context: ctx} = config, record, attrs \\ %{}) do
    fn_name = :"change_#{config.singular_name}"

    if has_function?(ctx, fn_name, 2) do
      apply(ctx, fn_name, [record, attrs])
    else
      # Fallback: try the schema's changeset function
      config.schema.changeset(record, attrs)
    end
  end

  defp has_function?(mod, fun, arity) do
    Code.ensure_loaded!(mod)
    function_exported?(mod, fun, arity)
  end

  defp raise_missing(ctx, fn_name, suggestion) do
    raise ArgumentError, """
    AdminKit: #{inspect(ctx)} does not export `#{fn_name}`.
    Expected to find: `def #{suggestion}`

    Either add this function to your context module, or implement the
    AdminKit.Resource callbacks directly in your resource module to override
    default delegation.
    """
  end
end
