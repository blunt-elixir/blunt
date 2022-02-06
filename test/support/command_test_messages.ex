defmodule Cqrs.CommandTest.Protocol do
  defmodule DispatchNoHandler do
    use Cqrs.Command

    field :name, :string, required: true
    field :dog, :string, default: "maize"
  end

  defmodule CommandViaCommandMacro do
    use Cqrs

    defcommand do
      field :name, :string, required: true
      field :dog, :string, default: "maize"
    end
  end

  defmodule DispatchWithHandler do
    use Cqrs.Command

    field :name, :string, required: true
    field :dog, :string, default: "maize"

    option :reply_to, :pid, required: true
    option :error_at, :enum, values: [:before_dispatch, :handle_authorize, :handle_dispatch]
  end

  defmodule DispatchWithHandlerHandler do
    use Cqrs.CommandHandler
    alias Cqrs.ExecutionContext, as: Context

    defp reply(context, pipeline) do
      context
      |> Context.get_option(:reply_to)
      |> send({pipeline, context})
    end

    @impl true
    def before_dispatch(command, context) do
      reply(context, :before_dispatch)

      if Context.get_option(context, :error_at) == :before_dispatch do
        {:error, :before_dispatch_error}
      else
        with {:ok, child} <- get_some_dependency(command) do
          {:ok, Context.put_private(context, :child, child)}
        end
      end
    end

    @impl true
    def handle_authorize(_command, context) do
      reply(context, :handle_authorize)

      if Context.get_option(context, :error_at) == :handle_authorize do
        {:error, :handle_authorize_error}
      else
        {:ok, context}
      end
    end

    @impl true
    def handle_dispatch(_command, context) do
      reply(context, :handle_dispatch)

      if Context.get_option(context, :error_at) == :handle_dispatch do
        {:error, :handle_dispatch_error}
      else
        "YO-HOHO"
      end
    end

    defp get_some_dependency(_command) do
      {:ok, %{related: "value"}}
    end
  end
end
