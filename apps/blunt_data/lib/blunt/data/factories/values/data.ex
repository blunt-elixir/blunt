defmodule Blunt.Data.Factories.Values.Data do
  @moduledoc false
  @derive Inspect
  defstruct [:field, :factory, lazy: false]

  alias Blunt.Data.Factories.Factory
  alias Blunt.Data.Factories.Values.Data

  defimpl Blunt.Data.Factories.Value do
    def declared_props(%Data{field: field}), do: [field]

    def evaluate(%Data{field: field, factory: factory, lazy: lazy}, acc, current_factory) do
      if not lazy or (lazy and not Map.has_key?(acc, field)) do
        operation =
          factory
          |> Map.fetch!(:operation)
          |> validate_factory_operation!(current_factory)

        opts =
          factory
          |> Map.get(:opts, [])
          |> Keyword.merge(current_factory.opts)

        factory_config =
          factory
          |> Map.put(:input, acc)
          |> Map.put(:opts, opts)
          |> Map.put(:operation, operation)
          |> Map.put(:name, current_factory.name)
          |> Map.put(:builders, current_factory.builders)
          |> Map.put(:fake_provider, current_factory.fake_provider)
          |> Map.put(:factory_module, current_factory.factory_module)

        value =
          Factory
          |> struct!(factory_config)
          |> Factory.build()

        value = Factory.log_value(current_factory, value, field, lazy, "data")

        Map.put(acc, field, value)
      else
        acc
      end
    end

    defp validate_factory_operation!(:dispatch, %{factory_module: module}) do
      if function_exported?(module, :dispatch, 1),
        do: :dispatch,
        else: :builder_dispatch
    end

    defp validate_factory_operation!(operation, %{factory_module: module, name: name}) do
      if function_exported?(module, operation, 1) do
        operation
      else
        funcs = module.__info__(:functions) |> Keyword.keys()

        raise UndefinedFunctionError,
          arity: 1,
          module: module,
          function: operation,
          reason: """
          Attempted to call #{operation} on #{inspect(module)} as part of the `#{name}` factory.

          Available functions: #{inspect(funcs)}
          """
      end
    end
  end
end
