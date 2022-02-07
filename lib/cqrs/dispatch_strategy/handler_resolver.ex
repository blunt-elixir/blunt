defmodule Cqrs.DispatchStrategy.HandlerResolver do
  alias Cqrs.{Behaviour, DispatchContext}

  defmodule Error do
    defexception [:message]
  end

  @type handler :: atom()
  @type message_module :: atom()
  @type behaviour_module :: atom()
  @type context :: DispatchContext.command_context() | DispatchContext.query_context()

  @callback resolve(message_module, behaviour_module) :: {:ok, handler} | :error

  @spec get_handler!(context, behaviour_module) :: handler
  @spec get_handler(context, behaviour_module) :: {:ok, handler} | {:error, any()} | :error

  @doc false
  def get_handler(%{message: %{__struct__: module}}, behaviour_module) do
    resolver().resolve(module, behaviour_module)
  end

  @doc false
  def get_handler!(%{message: %{__struct__: module}} = context, behaviour_module) do
    case get_handler(context, behaviour_module) do
      {:ok, handler} -> handler
      {:error, reason} -> raise Error, message: reason
      :error -> raise Error, message: "No #{inspect(behaviour_module)} found for query: #{inspect(module)}"
    end
  end

  defp resolver do
    :cqrs_tools
    |> Application.get_env(:handler_resolver, __MODULE__.Default)
    |> Behaviour.validate!(__MODULE__)
  end
end
