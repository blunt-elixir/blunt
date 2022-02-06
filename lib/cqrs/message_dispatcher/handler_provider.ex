defmodule Cqrs.MessageDispatcher.HandlerProvider do
  defmodule Error do
    defexception [:message]
  end

  alias Cqrs.{Behaviour, CommandHandler, ExecutionContext, QueryHandler}

  @type handler :: atom()
  @type context :: ExecutionContext.t()

  @spec get_handler(context) :: {:error, :no_handler} | {:ok, handler}
  @spec get_handler!(context) :: handler

  def get_handler(%{message_type: :command, message: %{__struct__: module}}),
    do: resolve_handler(module, CommandHandler)

  def get_handler(%{message_type: :query, message: %{__struct__: module}}),
    do: resolve_handler(module, QueryHandler)

  def get_handler!(%{message_type: :command, message: command} = context) do
    %{__struct__: module} = command

    case get_handler(context) do
      {:ok, handler} -> handler
      {:error, :no_handler} -> raise Error, message: "No CommandHandler found for query: #{inspect(module)}"
    end
  end

  def get_handler!(%{message_type: :query, message: query} = context) do
    %{__struct__: module} = query

    case get_handler(context) do
      {:ok, handler} -> handler
      {:error, :no_handler} -> raise Error, message: "No QueryHandler found for query: #{inspect(module)}"
    end
  end

  defp resolve_handler(module, behaviour_module) do
    with {:ok, handler_module} <- resolve_module(module) do
      Behaviour.validate(handler_module, behaviour_module)
    end
  end

  defp resolve_module(module) do
    {:ok, String.to_existing_atom(to_string(module) <> "Handler")}
  rescue
    _ -> {:error, :no_handler}
  end
end
