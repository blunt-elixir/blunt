defmodule Cqrs.Command do
  alias Cqrs.Message.Option
  alias Cqrs.Command.Events

  defmacro __using__(opts) do
    quote do
      use Cqrs.Message,
          [require_all_fields?: true]
          |> Keyword.merge(unquote(opts))
          |> Keyword.put(:dispatch?, true)
          |> Keyword.put(:message_type, :command)

      Module.register_attribute(__MODULE__, :events, accumulate: true)

      import Cqrs.Command, only: [derive_event: 1, derive_event: 2, derive_event: 3]

      @options Option.message_return()

      @before_compile Cqrs.Command
      @after_compile Cqrs.Command
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
      Module.delete_attribute(__MODULE__, :events)
    end
  end

  defmacro __after_compile__(env, _bytecode),
    do: Events.generate_events(env)
end
