if Code.ensure_loaded?(ExMachina) and Code.ensure_loaded?(Faker) do
  defmodule Blunt.Testing.ExMachina do
    alias Blunt.Testing.ExMachina
    alias Blunt.Testing.ExMachina.Generator
    require Blunt.Testing.ExMachina.Generator

    defmacro __using__(opts) do
      quote do
        Module.register_attribute(__MODULE__, :messages, accumulate: true)

        use Blunt.Testing.ExMachina.DispatchStrategy
        use ExMachina.Ecto, repo: Keyword.get(unquote(opts), :repo)

        import Blunt.Testing.ExMachina, only: :macros

        @before_compile Blunt.Testing.ExMachina
      end
    end

    defmacro factory(message, opts \\ []) do
      {body, opts} = Keyword.pop(opts, :do)

      quote bind_quoted: [message: message, opts: opts] do
        @messages {message, opts}
      end
    end

    defmacro const(field, value) do
      %ExMachina.ConstantValue{field: field, value: value}
    end

    defmacro __before_compile__(_env) do
      quote do
        factories = Enum.map(@messages, &Generator.generate/1)
        Module.eval_quoted(__MODULE__, factories)
      end
    end
  end
end
