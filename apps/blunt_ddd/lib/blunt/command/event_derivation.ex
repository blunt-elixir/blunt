defmodule Blunt.Command.EventDerivation do
  alias Blunt.Command.Events

  defmacro __using__(_opts) do
    quote do
      Module.register_attribute(__MODULE__, :events, accumulate: true)

      import Blunt.Command.EventDerivation, only: :macros

      @before_compile Blunt.Command.EventDerivation
      @after_compile Blunt.Command.EventDerivation
    end
  end

  defmacro derive_event(name, opts \\ [])

  defmacro derive_event(name, do: body) do
    body = Macro.escape(body, unquote: true)
    body = quote do: unquote(body)
    Events.record(name, do: body)
  end

  defmacro derive_event(name, opts),
    do: Events.record(name, opts)

  defmacro derive_event(name, opts, do: body) do
    body = Macro.escape(body, unquote: true)
    body = quote do: unquote(body)
    Events.record(name, Keyword.put(opts, :do, body))
  end

  defmacro __before_compile__(_env) do
    quote do
      def __events__, do: @events

      proxies = Enum.map(@events, &Events.generate_proxy/1)

      Module.eval_quoted(__MODULE__, proxies)

      Module.delete_attribute(__MODULE__, :events)
    end
  end

  defmacro __after_compile__(env, _bytecode),
    do: Events.generate_events(env)
end
