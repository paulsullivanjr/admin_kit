defmodule AdminKit.Resource.Compiler do
  @moduledoc false
  # Compile-time builder that converts raw DSL attributes into a ResourceConfig struct.
  # Raises ArgumentError with clear messages on misconfiguration.

  alias AdminKit.{ResourceConfig, Field, Action, Scope}

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
        policy
      ) do
    validate_schema!(schema)
    validate_context!(context)

    fields = build_fields(schema, raw_fields, index_fields, form_fields, searchable)
    actions = build_actions(raw_actions)
    scopes = build_scopes(raw_scopes)

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
    unless is_atom(schema) and function_exported?(schema, :__schema__, 1) do
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

  defp build_actions(raw_actions) do
    Enum.map(raw_actions, fn {name, opts} ->
      unless Keyword.has_key?(opts, :handler) do
        raise ArgumentError, "AdminKit: action #{inspect(name)} requires a :handler option"
      end

      %Action{
        name: name,
        label:
          Keyword.get(
            opts,
            :label,
            name |> to_string() |> String.replace("_", " ") |> String.capitalize()
          ),
        handler: Keyword.fetch!(opts, :handler),
        scope: Keyword.get(opts, :scope, :member),
        icon: Keyword.get(opts, :icon),
        confirm: Keyword.get(opts, :confirm),
        policy: Keyword.get(opts, :policy)
      }
    end)
  end

  defp build_scopes(raw_scopes) do
    Enum.map(raw_scopes, fn {name, opts} ->
      %Scope{
        name: name,
        label: Keyword.get(opts, :label, name |> to_string() |> String.capitalize()),
        filter: Keyword.get(opts, :filter, fn q -> q end),
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
