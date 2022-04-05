defmodule Blunt.Message.Dispatch do
  @moduledoc false

  alias Blunt.{DispatchContext, DispatchStrategy, Message.Dispatch, Message.Documentation}

  defmacro register(opts) do
    quote bind_quoted: [opts: opts] do
      dispatch? = Keyword.get(opts, :dispatch?, false)
      Module.put_attribute(__MODULE__, :dispatch?, dispatch?)
      @metadata dispatchable?: dispatch?
    end
  end

  def generate do
    quote do
      if @dispatch? do
        @doc Documentation.generate_dispatch_doc()
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

  def dispatch(message, opts) when is_struct(message) do
    dispatch({:ok, message}, opts)
  end

  def dispatch({:error, error}, _opts),
    do: {:error, error}

  def dispatch({:ok, message}, opts) do
    with {:ok, context} <- DispatchContext.new(message, opts) do
      if DispatchContext.async?(context),
        do: Task.async(fn -> do_dispatch(context) end),
        else: do_dispatch(context)
    end
  end

  defp do_dispatch(context) do
    context
    |> DispatchContext.Configuration.configure()
    |> DispatchStrategy.dispatch()
  end
end
