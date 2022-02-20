defmodule Cqrs.Message.Dispatch do
  @moduledoc false

  alias Cqrs.{DispatchContext, DispatchStrategy, Message.Dispatch, Message.Documentation}

  defmacro register(opts) do
    quote bind_quoted: [opts: opts] do
      dispatch? = Keyword.get(opts, :dispatch?, false)
      Module.put_attribute(__MODULE__, :dispatch?, dispatch?)
      @metadata dispatchable?: dispatch?
    end
  end

  defmacro generate do
    quote do
      if @dispatch? do
        @doc Documentation.generate_dispatch_docs()
        def dispatch(message, opts \\ []),
          do: Dispatch.dispatch(message, opts)

        @doc "Same as `dispatch` but asynchronously"
        def dispatch_async(message, opts \\ []),
          do: Dispatch.dispatch_async(message, opts)
      end
    end
  end

  def dispatch_async(message, opts),
    do: dispatch(message, Keyword.put(opts, :async, true))

  def dispatch({:error, error}, _opts),
    do: {:error, error}

  def dispatch({:ok, message, discarded_data}, opts) do
    with {:ok, context} <- DispatchContext.new(message, discarded_data, opts) do
      if DispatchContext.async?(context),
        do: Task.async(fn -> DispatchStrategy.dispatch(context) end),
        else: DispatchStrategy.dispatch(context)
    end
  end
end
