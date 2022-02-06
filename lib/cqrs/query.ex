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

      @options Option.message_return()

      option :execute, :boolean, default: true
      option :preload, {:array, :any}, default: []
      option :allow_nil_filters, :boolean, default: false
    end
  end

  def create_filter_list(query, context) do
    opts = Context.options(context) |> Enum.into(%{})

    query
    |> Map.from_struct()
    |> Map.drop([:discarded_input])
    |> reject_nil_filters(opts)
  end

  defp reject_nil_filters(filters, %{allow_nil_filters: false}),
    do: Enum.reject(filters, &match?({_key, nil}, &1))

  defp reject_nil_filters(filters, _opts),
    do: filters
end
