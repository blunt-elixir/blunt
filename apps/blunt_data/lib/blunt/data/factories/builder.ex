defmodule Blunt.Data.Factories.Builder do
  @type field_type :: Ecto.Type.t() | atom()
  @type field_info :: {name :: atom(), type :: field_type(), opts :: keyword()}
  @type message_module :: module()
  @type final_message :: struct() | map()

  @callback recognizes?(message_module) :: boolean()
  @callback message_fields(message_module()) :: [field_info()]
  @callback field_validations(message_module()) :: [{atom(), atom()}]

  @callback build(message_module(), data :: map()) :: final_message
  @callback dispatch(final_message()) :: any()

  defmodule NoBuilderError do
    defexception [:message]

    def message(%{message: message}) do
      message <> ". Messages are expected to either be a map or struct"
    end
  end

  defmacro __using__(_opts) do
    quote do
      @behaviour Blunt.Data.Factories.Builder

      @impl true
      def dispatch(final_message), do: final_message

      @impl true
      def field_validations(_message_module), do: []

      defoverridable dispatch: 1, field_validations: 1
    end
  end
end
