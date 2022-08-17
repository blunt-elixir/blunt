defmodule Blunt.Query do
  alias Blunt.Message.{Metadata, Options}
  alias Blunt.DispatchContext, as: Context

  defmacro __using__(opts) do
    opts =
      [require_all_fields?: false]
      |> Keyword.merge(opts)
      |> Keyword.put(:dispatch?, true)
      |> Keyword.put(:message_type, :query)

    quote do
      require Blunt.Message.Options

      use Blunt.Message, unquote(opts)

      Options.register()

      @options [
        Options.query_return_option(),
        {:preload, {:array, :any},
         [
           default: [],
           required: false,
           desc: "A list of preloads to append to the query"
         ]},
        {:allow_nil_filters, :boolean,
         [
           default: false,
           required: false,
           desc: "If `false`, all fields with a value of `nil` will be removed from the filters"
         ]}
      ]

      Module.register_attribute(__MODULE__, :bindings, accumulate: true)

      @before_compile Blunt.Query

      import Blunt.Query, only: :macros
    end
  end

  @spec option(name :: atom(), type :: any(), keyword()) :: any()
  defmacro option(name, type, opts \\ []) when is_atom(name) and is_list(opts),
    do: Options.record(name, type, opts)

  @spec binding(atom(), atom()) :: any()
  defmacro binding(name, target_schema) do
    quote do
      @bindings {unquote(name), unquote(target_schema)}
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      Options.generate()
      @metadata bindings: Module.delete_attribute(__MODULE__, :bindings)
    end
  end

  @spec create_filter_list(Blunt.DispatchContext.query_context()) :: list | map
  def create_filter_list(%{message_type: :query, message: filter_map} = context) do
    opts = Context.options_map(context)

    filter_map
    |> Map.from_struct()
    |> Map.delete(:__blunt_id)
    |> reject_nil_filters(opts)
  end

  defp reject_nil_filters(filters, %{allow_nil_filters: false}),
    do: Enum.reject(filters, &match?({_key, nil}, &1))

  defp reject_nil_filters(filters, _opts),
    do: filters

  @spec query(Blunt.DispatchContext.query_context()) :: any | nil
  def query(context), do: Context.get_private(context, :query)

  @spec filters(Blunt.DispatchContext.query_context()) :: map()
  def filters(context), do: Context.get_private(context, :filters)

  @spec message(Blunt.DispatchContext.query_context()) :: struct()
  def message(%{message: message}), do: message

  @spec preload(Blunt.DispatchContext.query_context()) :: list()
  def preload(context), do: Context.get_option(context, :preload)

  @spec results(Blunt.DispatchContext.query_context()) :: any | nil
  defdelegate results(context), to: Context, as: :get_last_pipeline

  @spec get_metadata(Context.query_context(), atom, any) :: any | nil
  defdelegate get_metadata(context, key, default \\ nil), to: Context

  @spec options(Context.t()) :: list()
  def options(%{message_module: module}), do: Metadata.get(module, :options, [])

  @spec bindings(Context.t()) :: list()
  def bindings(%{message_module: module}), do: Metadata.get(module, :bindings, [])
end
