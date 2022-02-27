if Code.ensure_loaded?(ExMachina) and Code.ensure_loaded?(Faker) do
  defmodule Blunt.Testing.Factories.DispatchStrategy do
    @moduledoc false
    use ExMachina.Strategy, function_name: :bispatch

    defmodule Error do
      defexception [:message]
    end

    alias Blunt.Message.Metadata
    alias Blunt.{DispatchContext, Message}

    def handle_bispatch(message, opts),
      do: handle_bispatch(message, opts, [])

    def handle_bispatch(%{__struct__: module} = message, _opts, dispatch_opts) do
      unless Message.dispatchable?(message) do
        raise Error, message: "#{inspect(module)} is not a dispatchable message"
      end

      dispatch_opts =
        dispatch_opts
        |> Keyword.put(:dispatched_from, :ex_machina)
        |> Keyword.update(:return, :context, &Function.identity/1)
        |> Keyword.put(:user_supplied_fields, Metadata.field_names(module))

      case module.dispatch({:ok, message, %{}}, dispatch_opts) do
        {:error, %DispatchContext{errors: errors}} ->
          {:error, errors}

        {:ok, %DispatchContext{} = context} ->
          case DispatchContext.get_last_pipeline(context) do
            {:ok, result} -> {:ok, result}
            result -> {:ok, result}
          end

        other ->
          other
      end
    end
  end
end
