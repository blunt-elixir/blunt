defmodule Cqrs.DispatchStrategy.HandlerResolver do
  # TODO: Document :cqrs_tools, :handler_resolver

  alias Cqrs.{Behaviour, CommandHandler, DispatchContext, DispatchError, QueryHandler}

  @type handler :: atom()
  @type message_module :: atom()
  @type behaviour_module :: atom()
  @type context :: DispatchContext.command_context() | DispatchContext.query_context()

  @callback resolve(message_module, behaviour_module()) :: {:ok, handler} | :error

  @spec get_handler!(context) :: handler
  @spec get_handler(context) :: {:ok, handler} | :error

  @doc false
  def get_handler(%{message_type: :command, message: %{__struct__: module}}),
    do: resolver().resolve(module, CommandHandler)

  @doc false
  def get_handler(%{message_type: :query, message: %{__struct__: module}}),
    do: resolver().resolve(module, QueryHandler)

  @doc false
  def get_handler!(%{message_type: :command, message: command} = context) do
    %{__struct__: module} = command

    case get_handler(context) do
      {:ok, handler} -> handler
      :error -> raise DispatchError, message: "No CommandHandler found for query: #{inspect(module)}"
    end
  end

  @doc false
  def get_handler!(%{message_type: :query, message: query} = context) do
    %{__struct__: module} = query

    case get_handler(context) do
      {:ok, handler} -> handler
      :error -> raise DispatchError, message: "No QueryHandler found for query: #{inspect(module)}"
    end
  end

  defp resolver do
    :cqrs_tools
    |> Application.get_env(:handler_resolver, __MODULE__.Default)
    |> Behaviour.validate!(__MODULE__)
  end
end
