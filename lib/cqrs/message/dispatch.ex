defmodule Cqrs.Message.Dispatch do
  @moduledoc false

  alias Cqrs.{DispatchContext, DispatchStrategy, Message.Dispatch}

  defmacro generate do
    quote do
      def dispatch(message, opts \\ []),
        do: Dispatch.apply(message, opts)

      def dispatch_async(message, opts \\ []),
        do: Dispatch.apply(message, Keyword.put(opts, :async, true))
    end
  end

  def apply({:ok, message, discarded_data}, opts) do
    with {:ok, context} <- DispatchContext.new(message, discarded_data, opts) do
      if DispatchContext.async?(context),
        do: Task.async(fn -> DispatchStrategy.dispatch(context) end),
        else: DispatchStrategy.dispatch(context)
    end
  end

  def apply({:error, error}, _opts),
    do: {:error, error}
end
