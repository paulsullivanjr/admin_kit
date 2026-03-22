defmodule AdminKit.Resource.DSL do
  @moduledoc false
  # DSL helper macros — imported inside resource/2 block only.

  defmacro context(mod) do
    quote do: Module.put_attribute(__MODULE__, :ak_context, unquote(mod))
  end

  defmacro field(name, opts \\ []) do
    quote do
      Module.put_attribute(__MODULE__, :ak_fields, {unquote(name), unquote(opts)})
    end
  end

  defmacro index_fields(names) do
    quote do: Module.put_attribute(__MODULE__, :ak_index_fields, unquote(names))
  end

  defmacro form_fields(names) do
    quote do: Module.put_attribute(__MODULE__, :ak_form_fields, unquote(names))
  end

  defmacro action(name, opts) do
    # Extract handler — if it's an anonymous function, generate a named
    # wrapper so it can be stored in a module attribute.
    {handler_ast, safe_opts} = Keyword.pop(opts, :handler)
    handler_fn_name = :"__ak_action_handler_#{name}__"

    quote do
      defp unquote(handler_fn_name)(record), do: unquote(handler_ast).(record)

      Module.put_attribute(
        __MODULE__,
        :ak_actions,
        {unquote(name), [{:_handler_fn, unquote(handler_fn_name)} | unquote(safe_opts)]}
      )
    end
  end

  defmacro scope(name, opts \\ []) do
    {filter_ast, safe_opts} = Keyword.pop(opts, :filter)

    if filter_ast do
      filter_fn_name = :"__ak_scope_filter_#{name}__"

      quote do
        defp unquote(filter_fn_name)(query), do: unquote(filter_ast).(query)

        Module.put_attribute(
          __MODULE__,
          :ak_scopes,
          {unquote(name), [{:_filter_fn, unquote(filter_fn_name)} | unquote(safe_opts)]}
        )
      end
    else
      quote do
        Module.put_attribute(__MODULE__, :ak_scopes, {unquote(name), unquote(safe_opts)})
      end
    end
  end

  defmacro searchable_fields(names) do
    quote do: Module.put_attribute(__MODULE__, :ak_searchable, unquote(names))
  end

  defmacro per_page(n) do
    quote do: Module.put_attribute(__MODULE__, :ak_per_page, unquote(n))
  end

  defmacro policy(mod) do
    quote do: Module.put_attribute(__MODULE__, :ak_policy, unquote(mod))
  end
end
