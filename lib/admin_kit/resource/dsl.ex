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
    quote do
      Module.put_attribute(__MODULE__, :ak_actions, {unquote(name), unquote(opts)})
    end
  end

  defmacro scope(name, opts \\ []) do
    quote do
      Module.put_attribute(__MODULE__, :ak_scopes, {unquote(name), unquote(opts)})
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
