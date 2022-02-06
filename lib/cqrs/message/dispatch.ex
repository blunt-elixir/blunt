defmodule Cqrs.Message.Dispatch do
  @moduledoc false

  alias Cqrs.{ExecutionContext, MessageDispatcher, Message.Dispatch}

  defmacro generate do
    quote do
      def dispatch(message, opts \\ []),
        do: Dispatch.apply(message, opts)

      def dispatch_async(message, opts \\ []),
        do: Dispatch.apply(message, Keyword.put(opts, :async, true))
    end
  end

  def apply({:ok, message}, opts) do
    with {:ok, context} <- ExecutionContext.new(message, opts) do
      if ExecutionContext.async?(context),
        do: Task.async(fn -> MessageDispatcher.dispatch(context) end),
        else: MessageDispatcher.dispatch(context)
    end
  end

  def apply({:error, error}, _opts),
    do: {:error, error}
end
