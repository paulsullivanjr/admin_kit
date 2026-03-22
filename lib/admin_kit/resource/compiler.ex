defmodule AdminKit.Resource.Compiler do
  @moduledoc false
  # Compile-time builder that converts raw DSL attributes into a ResourceConfig struct.
  # Raises ArgumentError with clear messages on misconfiguration.

  alias AdminKit.{ResourceConfig, Field, Action, Scope}

  @doc "Validates schema and context at compile time (non-function checks only)."
  def validate_compile_time!(schema, context) do
    validate_schema!(schema)
    validate_context!(context)
  end

  def compile(
        schema,
        context,
        raw_fields,
        index_fields,
        form_fields,
        raw_actions,
        raw_scopes,
        searchable,
        per_page,
        policy,
        resource_module
      ) do
    validate_schema!(schema)
    validate_context!(context)

    fields = build_fields(schema, raw_fields, index_fields, form_fields, searchable)
    actions = build_actions(raw_actions, resource_module)
    scopes = build_scopes(raw_scopes, resource_module)

    %ResourceConfig{
      schema: schema,
      context: context,
      singular_name: infer_singular(schema),
      plural_name: infer_plural(schema),
      fields: fields,
      index_fields: index_fields,
      form_fields: form_fields,
      actions: actions,
      scopes: scopes,
      searchable_fields: searchable,
      per_page: per_page,
      policy: policy
    }
  end

  defp validate_schema!(schema) do
    unless is_atom(schema) do
      raise ArgumentError, """
      AdminKit: #{inspect(schema)} does not appear to be an Ecto schema.
      Make sure you pass the schema module, not a context module.
      """
    end

    Code.ensure_compiled!(schema)

    unless function_exported?(schema, :__schema__, 1) do
      raise ArgumentError, """
      AdminKit: #{inspect(schema)} does not appear to be an Ecto schema.
      Make sure you pass the schema module, not a context module.
      """
    end
  end

  defp validate_context!(nil) do
    raise ArgumentError, "AdminKit: `context` is required inside every resource block."
  end

  defp validate_context!(_), do: :ok

  defp build_fields(schema, raw_fields, index_fields, form_fields, searchable) do
    all_schema_fields = schema.__schema__(:fields)
    raw_field_map = Map.new(raw_fields)

    all_fields = Enum.uniq(index_fields ++ form_fields)

    Enum.map(all_fields, fn name ->
      unless name in all_schema_fields do
        raise ArgumentError,
              "AdminKit: field #{inspect(name)} is not defined on #{inspect(schema)}"
      end

      opts = Map.get(raw_field_map, name, [])
      type = Keyword.get(opts, :type) || infer_type(schema.__schema__(:type, name))

      %Field{
        name: name,
        type: type,
        label: Keyword.get(opts, :label),
        opts: opts,
        show_in_index: name in index_fields,
        show_in_form: name in form_fields,
        readonly: Keyword.get(opts, :readonly, false),
        sortable: Keyword.get(opts, :sortable, true),
        searchable: name in searchable
      }
    end)
  end

  defp build_actions(raw_actions, resource_module) do
    Enum.map(raw_actions, fn {name, opts} ->
      # Resolve handler: either a _handler_fn reference to a generated function,
      # or a direct :handler value (remote function reference like &Mod.fun/1)
      handler =
        case Keyword.get(opts, :_handler_fn) do
          nil ->
            Keyword.get(opts, :handler) ||
              raise ArgumentError,
                    "AdminKit: action #{inspect(name)} requires a :handler option"

          fn_name ->
            Function.capture(resource_module, fn_name, 1)
        end

      %Action{
        name: name,
        label:
          Keyword.get(
            opts,
            :label,
            name |> to_string() |> String.replace("_", " ") |> String.capitalize()
          ),
        handler: handler,
        scope: Keyword.get(opts, :scope, :member),
        icon: Keyword.get(opts, :icon),
        confirm: Keyword.get(opts, :confirm),
        policy: Keyword.get(opts, :policy)
      }
    end)
  end

  defp build_scopes(raw_scopes, resource_module) do
    Enum.map(raw_scopes, fn {name, opts} ->
      # Resolve filter: either a _filter_fn reference to a generated function,
      # or a direct :filter value, or a default passthrough
      filter =
        case Keyword.get(opts, :_filter_fn) do
          nil -> Keyword.get(opts, :filter, fn q -> q end)
          fn_name -> Function.capture(resource_module, fn_name, 1)
        end

      %Scope{
        name: name,
        label: Keyword.get(opts, :label, name |> to_string() |> String.capitalize()),
        filter: filter,
        default: Keyword.get(opts, :default, false)
      }
    end)
  end

  defp infer_type(:string), do: :string
  defp infer_type(:integer), do: :integer
  defp infer_type(:boolean), do: :boolean
  defp infer_type(:date), do: :date
  defp infer_type(:naive_datetime), do: :datetime
  defp infer_type(:utc_datetime), do: :datetime
  defp infer_type({:parameterized, Ecto.Enum, _}), do: :select
  defp infer_type(_), do: :string

  defp infer_singular(schema) do
    schema |> Module.split() |> List.last() |> Macro.underscore()
  end

  defp infer_plural(schema) do
    infer_singular(schema) <> "s"
  end
end
