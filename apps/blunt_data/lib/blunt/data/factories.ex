if Code.ensure_loaded?(ExMachina) and Code.ensure_loaded?(Faker) do
  defmodule Blunt.Data.Factories do
    alias Blunt.Behaviour
    alias Blunt.Data.Factories.{Builder, Factory}
    alias Blunt.Data.Factories.Builder.{EctoSchemaBuilder, StructBuilder, MapBuilder}

    defmacro __using__(_opts) do
      quote do
        @after_compile Blunt.Data.Factories

        defmacro __using__(_opts) do
          quote do
            use Blunt.Data.Factories
          end
        end

        import Blunt.Data.Factories, only: :macros
        import Blunt.Data.Factories.Values, only: :macros

        Module.register_attribute(__MODULE__, :builders, accumulate: true)

        Module.put_attribute(__MODULE__, :builders, MapBuilder)
        Module.put_attribute(__MODULE__, :builders, StructBuilder)
        Module.put_attribute(__MODULE__, :builders, EctoSchemaBuilder)
      end
    end

    defmacro __after_compile__(%{module: module}, _code) do
      module
      |> Module.get_attribute(:builders)
      |> Enum.each(&Behaviour.validate!(&1, Builder))
    end

    defmacro builder(module) do
      quote do
        @builders unquote(module)
      end
    end

    defmacro factory(message) do
      create_factory(message, [], [])
    end

    defmacro factory(message, do: body) do
      values = extract_values(body)
      create_factory(message, values, [])
    end

    defmacro factory(message, opts) do
      create_factory(message, [], opts)
    end

    defmacro factory(message, opts, do: body) do
      values = extract_values(body)
      create_factory(message, values, opts)
    end

    defp extract_values({:__block__, _meta, elements}), do: elements
    defp extract_values(nil), do: []
    defp extract_values(list) when is_list(list), do: list
    defp extract_values(element), do: [element]

    defp create_factory(message, values, opts) do
      {name, opts} = factory_name(message, opts)

      {name, message} =
        case name do
          {:map_factory, name} -> {name, Map}
          _ -> {name, message}
        end

      quote do
        @active_builders Module.get_attribute(__MODULE__, :builders)

        def unquote(name)(input) do
          factory = %Factory{
            input: input,
            name: unquote(name),
            opts: unquote(opts),
            values: unquote(values),
            message: unquote(message),
            operation: :build,
            factory_module: __MODULE__,
            builders: @active_builders
          }

          Factory.build(factory)
        end
      end
    end

    defp factory_name(message, opts) when is_atom(message) do
      name = String.to_atom("#{message}_factory")
      {{:map_factory, name}, opts}
    end

    defp factory_name({:__aliases__, _meta, message}, opts) do
      case Keyword.pop(opts, :as, nil) do
        {name, opts} when is_atom(name) and not is_nil(name) ->
          factory_name = String.to_atom(to_string(name) <> "_factory")
          {factory_name, opts}

        {_, opts} ->
          factory_name =
            message
            |> List.last()
            |> to_string()
            |> Macro.underscore()
            |> Kernel.<>("_factory")
            |> String.to_atom()

          {factory_name, opts}
      end
    end
  end
end
