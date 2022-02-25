if Code.ensure_loaded?(ExMachina) and Code.ensure_loaded?(Faker) do
  defmodule Blunt.Testing.ExMachina do
    alias Blunt.Testing.ExMachina.Factory

    defmacro __using__(opts) do
      repo = Keyword.get(opts, :repo)

      quote do
        use Blunt.Testing.ExMachina.DispatchStrategy

        if unquote(repo) do
          use ExMachina.Ecto, repo: unquote(repo)
        else
          use ExMachina
        end

        import Blunt.Testing.ExMachina, only: :macros
        import Blunt.Testing.ExMachina.Values, only: :macros
      end
    end

    defmacro factory(message) do
      factory_name = factory_name(message, [])
      create_factory(factory_name, message: message, values: [])
    end

    defmacro factory(message, do: body) do
      values = extract_values(body)
      factory_name = factory_name(message, [])
      create_factory(factory_name, message: message, values: values)
    end

    defmacro factory(message, opts) do
      factory_name = factory_name(message, opts)
      create_factory(factory_name, message: message, values: [])
    end

    defmacro factory(message, opts, do: body) do
      values = extract_values(body)
      factory_name = factory_name(message, opts)
      create_factory(factory_name, message: message, values: values)
    end

    defp extract_values({:__block__, _meta, elements}), do: elements
    defp extract_values(nil), do: []
    defp extract_values(element), do: [element]

    def create_factory(name, opts) do
      message = Keyword.fetch!(opts, :message)
      values = Keyword.fetch!(opts, :values)

      quote do
        def unquote(name)(attrs) do
          Factory.build(%Factory{message: unquote(message), values: unquote(values)}, attrs, unquote(opts))
        end
      end
    end

    defp factory_name({:__aliases__, _meta, message}, opts) do
      case Keyword.get(opts, :as, nil) do
        name when is_atom(name) and not is_nil(name) ->
          String.to_atom(to_string(name) <> "_factory")

        _ ->
          message
          |> List.last()
          |> to_string()
          |> Macro.underscore()
          |> Kernel.<>("_factory")
          |> String.to_atom()
      end
    end
  end
end
