if Code.ensure_loaded?(ExMachina) and Code.ensure_loaded?(Faker) do
  defmodule Blunt.Testing.ExMachina.DispatchStrategy do
    use ExMachina.Strategy, function_name: :dispatch

    defmodule Error do
      defexception [:message]
    end

    alias Blunt.Message

    def handle_dispatch(message, opts),
      do: handle_dispatch(message, opts, [])

    def handle_dispatch(%{__struct__: module} = message, _opts, dispatch_opts) do
      unless Message.dispatchable?(message) do
        raise Error, message: "#{inspect(module)} is not a dispatchable message"
      end

      {user_supplied_fields, message} = Map.pop(message, :user_supplied_fields, [])

      dispatch_opts =
        dispatch_opts
        |> Keyword.put(:dispatched_from, :ex_machina)
        |> Keyword.put(:user_supplied_fields, user_supplied_fields)

      module.dispatch({:ok, message, %{}}, dispatch_opts)
    end
  end
end
