defmodule Cqrs.Query do
  alias Cqrs.Message.Option
  alias Cqrs.ExecutionContext, as: Context

  defmacro __using__(opts) do
    quote do
      use Cqrs.Message,
          [require_all_fields?: false]
          |> Keyword.merge(unquote(opts))
          |> Keyword.put(:dispatch?, true)
          |> Keyword.put(:message_type, :query)

      Module.register_attribute(__MODULE__, :options, accumulate: true)
      Module.register_attribute(__MODULE__, :bindings, accumulate: true)

      @before_compile Cqrs.Query

      import Cqrs.Query, only: :macros

      @options Option.message_return()

      @options {:execute, [type: :boolean, default: true, required: true]}
      @options {:preload, [type: {:array, :any}, default: [], required: true]}
      @options {:allow_nil_filters, [type: :boolean, default: false, required: true]}
    end
  end

  @spec option(name :: atom(), type :: any(), keyword()) :: any()
  defmacro option(name, type, opts \\ []) when is_atom(name) and is_list(opts),
    do: Option.record(name, type, opts)

  @spec binding(atom(), atom(), keyword()) :: any()
  defmacro binding(name, target_schema, opts \\ []) do
    quote do
      @bindings {unquote(name), unquote(target_schema), unquote(opts)}
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def __options__, do: @options
      def __bindings__, do: @bindings

      Module.delete_attribute(__MODULE__, :options)
      Module.delete_attribute(__MODULE__, :bindings)
    end
  end

  def create_filter_list(query, context) do
    opts = Context.options(context) |> Enum.into(%{})

    query
    |> Map.from_struct()
    |> reject_nil_filters(opts)
  end

  defp reject_nil_filters(filters, %{allow_nil_filters: false}),
    do: Enum.reject(filters, &match?({_key, nil}, &1))

  defp reject_nil_filters(filters, _opts),
    do: filters
end
