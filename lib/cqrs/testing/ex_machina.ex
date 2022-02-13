if Code.ensure_loaded?(ExMachina) and Code.ensure_loaded?(Faker) do
  defmodule Cqrs.Testing.ExMachina do
    alias Cqrs.Testing.ExMachina.Generator

    defmacro __using__(_opts) do
      quote do
        Module.register_attribute(__MODULE__, :messages, accumulate: true)

        use ExMachina
        use Cqrs.Testing.ExMachina.DispatchStrategy

        import Cqrs.Testing.ExMachina, only: :macros

        @before_compile Cqrs.Testing.ExMachina
      end
    end

    defmacro factory(message, opts \\ []) do
      quote do
        @messages {unquote(message), unquote(opts)}
      end
    end

    defmacro __before_compile__(_env) do
      quote do
        factories = Enum.map(@messages, &Generator.generate/1)
        Module.eval_quoted(__MODULE__, factories)
      end
    end
  end
end
