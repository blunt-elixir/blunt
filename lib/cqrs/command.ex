defmodule Cqrs.Command do
  alias Cqrs.Message.Option
  alias Cqrs.Command.Events
  alias Cqrs.DispatchContext, as: Context

  defmacro __using__(opts) do
    opts =
      [require_all_fields?: true]
      |> Keyword.merge(opts)
      |> Keyword.put(:dispatch?, true)
      |> Keyword.put(:message_type, :command)

    quote do
      use Cqrs.Message, unquote(opts)

      Module.put_attribute(__MODULE__, :require_all_fields?, Keyword.fetch!(unquote(opts), :require_all_fields?))

      Module.register_attribute(__MODULE__, :events, accumulate: true)
      Module.register_attribute(__MODULE__, :options, accumulate: true)
      Module.register_attribute(__MODULE__, :internal_fields, accumulate: true)

      import Cqrs.Command, only: :macros

      @options Option.return_option()

      @before_compile Cqrs.Command
      @after_compile Cqrs.Command
    end
  end

  @spec option(name :: atom(), type :: any(), keyword()) :: any()
  defmacro option(name, type, opts \\ []) when is_atom(name) and is_list(opts),
    do: Option.record(name, type, opts)

  @spec internal_field(name :: atom(), type :: atom(), keyword()) :: any()
  defmacro internal_field(name, type, opts \\ []) do
    quote do
      @internal_fields {unquote(name), unquote(type),
                        Keyword.put(unquote(opts), :internal, true)
                        |> Keyword.put(:require_all_fields?, @require_all_fields?)}
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
    internal_fields =
      quote do
        Enum.map(@internal_fields, fn {name, type, opts} ->
          field(name, type, opts)
        end)
      end

    quote do
      def __events__, do: @events
      def __options__, do: @options

      unquote(internal_fields)

      Module.delete_attribute(__MODULE__, :events)
      Module.delete_attribute(__MODULE__, :options)
      Module.delete_attribute(__MODULE__, :require_all_fields?)
    end
  end

  defmacro __after_compile__(env, _bytecode),
    do: Events.generate_events(env)

  @spec results(Context.command_context()) :: any | nil
  def results(context), do: Context.get_last_pipeline(context)

  @spec private(Context.command_context()) :: map()
  def private(context), do: Context.get_private(context)

  @spec errors(Context.command_context()) :: map()
  def errors(context), do: Context.errors(context)
end
