defmodule Cqrs.DomainEvent do
  defmacro __using__(opts) do
    quote do
      use Cqrs.Message,
          [require_all_fields?: false]
          |> Keyword.merge(unquote(opts))
          |> Keyword.put(:message_type, :event)

      @type values :: Cqrs.Message.Input.t()
      @type overrides :: Cqrs.Message.Input.t()

      @spec create(values(), overrides()) :: struct() | {:error, any()}

      def create(values, overrides \\ []) do
        with {:ok, event, _discarded_data} <- new(values, overrides) do
          event
        end
      end
    end
  end
end
