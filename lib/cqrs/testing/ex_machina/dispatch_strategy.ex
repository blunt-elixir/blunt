if Code.ensure_loaded?(ExMachina) and Code.ensure_loaded?(Faker) do
  defmodule Cqrs.Testing.ExMachina.DispatchStrategy do
    use ExMachina.Strategy, function_name: :dispatch

    defmodule Error do
      defexception [:message]
    end

    alias Cqrs.Message

    def handle_dispatch(message, opts),
      do: handle_dispatch(message, opts, [])

    def handle_dispatch(%{__struct__: module} = message, _opts, dispatch_opts) do
      unless Message.dispatchable?(message) do
        raise Error, message: "#{inspect(module)} is not a dispatchable message"
      end

      module.dispatch({:ok, message, %{}}, dispatch_opts)
    end
  end
end
