defmodule Cqrs.Query do
  alias Cqrs.Message.Option
  alias Cqrs.DispatchContext, as: Context

  defmacro __using__(opts) do
    opts =
      [require_all_fields?: false]
      |> Keyword.merge(opts)
      |> Keyword.put(:dispatch?, true)
      |> Keyword.put(:message_type, :query)

    quote do
      use Cqrs.Message, unquote(opts)

      Module.register_attribute(__MODULE__, :options, accumulate: true)
      Module.register_attribute(__MODULE__, :bindings, accumulate: true)

      @before_compile Cqrs.Query

      import Cqrs.Query, only: :macros

      @options Option.return_option()

      @options {:execute, [type: :boolean, default: true, required: true]}
      @options {:preload, [type: {:array, :any}, default: [], required: true]}
      @options {:allow_nil_filters, [type: :boolean, default: false, required: true]}
    end
  end

  @spec option(name :: atom(), type :: any(), keyword()) :: any()
  defmacro option(name, type, opts \\ []) when is_atom(name) and is_list(opts),
    do: Option.record(name, type, opts)

  @spec binding(atom(), atom()) :: any()
  defmacro binding(name, target_schema) do
    quote do
      @bindings {unquote(name), unquote(target_schema)}
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

  @spec create_filter_list(Cqrs.DispatchContext.query_context()) :: list | map
  def create_filter_list(%{message_type: :query, message: filter_map} = context) do
    opts = Context.options(context) |> Enum.into(%{})

    filter_map
    |> Map.from_struct()
    |> reject_nil_filters(opts)
  end

  defp reject_nil_filters(filters, %{allow_nil_filters: false}),
    do: Enum.reject(filters, &match?({_key, nil}, &1))

  defp reject_nil_filters(filters, _opts),
    do: filters

  @spec bindings(Cqrs.DispatchContext.query_context()) :: map()
  def bindings(context), do: Context.get_private(context, :bindings)

  @spec query(Cqrs.DispatchContext.query_context()) :: any | nil
  def query(context), do: Context.get_private(context, :query)

  @spec filters(Cqrs.DispatchContext.query_context()) :: map()
  def filters(context), do: Context.get_private(context, :filters)

  @spec message(Cqrs.DispatchContext.query_context()) :: struct()
  def message(%{message: message}), do: message

  @spec results(Cqrs.DispatchContext.query_context()) :: any | nil
  def results(context), do: Context.get_last_pipeline(context)
end
