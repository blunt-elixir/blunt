defmodule Cqrs.Command do
  alias Cqrs.Message.Option
  alias Cqrs.DispatchContext, as: Context

  defmacro __using__(opts) do
    opts =
      [require_all_fields?: true]
      |> Keyword.merge(opts)
      |> Keyword.put(:dispatch?, true)
      |> Keyword.put(:message_type, :command)

    quote do
      use Cqrs.Message, unquote(opts)

      Module.register_attribute(__MODULE__, :options, accumulate: true)

      import Cqrs.Command, only: :macros

      @options Option.return_option()

      @before_compile Cqrs.Command
    end
  end

  @spec option(name :: atom(), type :: any(), keyword()) :: any()
  defmacro option(name, type, opts \\ []) when is_atom(name) and is_list(opts),
    do: Option.record(name, type, opts)

  defmacro __before_compile__(_env) do
    quote do
      def __options__, do: @options

      Module.delete_attribute(__MODULE__, :options)
    end
  end

  @spec results(Context.command_context()) :: any | nil
  defdelegate results(context), to: Context, as: :get_last_pipeline

  @spec private(Context.command_context()) :: map()
  defdelegate private(context), to: Context, as: :get_private

  @spec errors(Context.command_context()) :: map()
  defdelegate errors(context), to: Context

  @spec user_supplied_fields(Context.command_context()) :: map()
  defdelegate user_supplied_fields(context), to: Context

  @spec take_user_supplied_data(Context.command_context()) :: map()
  defdelegate take_user_supplied_data(context), to: Context

  @spec get_metadata(Context.command_context(), atom, any) :: any | nil
  defdelegate get_metadata(context, key, default \\ nil), to: Context
end
