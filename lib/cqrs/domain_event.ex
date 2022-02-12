defmodule Cqrs.DomainEvent do
  defmacro __using__(opts) do
    quote do
      use Cqrs.Message,
          [require_all_fields?: false]
          |> Keyword.merge(unquote(opts))
          |> Keyword.put(:versioned?, true)
          |> Keyword.put(:message_type, :event)

      @type values :: Cqrs.Message.Input.t()
      @type overrides :: Cqrs.Message.Input.t()

      @spec create(values(), overrides()) :: struct() | {:error, any()}
      def create(values, overrides \\ []),
        do: Cqrs.DomainEvent.create(__MODULE__, values, overrides)
    end
  end

  @doc false
  def create(module, values, overrides \\ []) do
    with {:ok, event, _discarded_data} <- module.new(values, overrides) do
      event
    end
  end
end
