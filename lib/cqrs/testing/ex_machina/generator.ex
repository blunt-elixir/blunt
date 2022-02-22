if Code.ensure_loaded?(ExMachina) and Code.ensure_loaded?(Faker) do
  defmodule Cqrs.Testing.ExMachina.Generator do
    @moduledoc false

    defmodule Error do
      defexception [:errors]

      def message(%{errors: errors}) do
        inspect(errors)
      end
    end

    alias Cqrs.Message.Metadata
    alias Cqrs.{DispatchContext, Message}
    alias Cqrs.Testing.ExMachina.Generator

    def generate({message, opts}) do
      factory_name = factory_name(message, opts)

      quote generated: true do
        def unquote(factory_name)(attrs) do
          Generator.create_message(unquote(message), attrs, unquote(opts))
        end
      end
    end

    def create_message(message, attrs, opts) do
      case Cqrs.Behaviour.validate(message, Cqrs.Message) do
        {:error, _} ->
          struct!(message, attrs)

        {:ok, message} ->
          data =
            attrs
            |> satisfy_dependencies(opts)
            |> generate_fake_data(message)
            |> populate_data_from_opts(opts)

          if Keyword.get(opts, :debug, false) do
            IO.inspect(data, label: inspect(message))
          end

          user_supplied_fields = Map.keys(data)

          case message.new(data) do
            {:ok, message, _discarded_data} ->
              message

            {:ok, message} ->
              message

            {:error, errors} ->
              raise Error, errors: errors

            message ->
              message
          end
          |> Map.put(:user_supplied_fields, user_supplied_fields)
      end
    end

    def populate_data_from_opts(attrs, opts) do
      opts
      |> Keyword.get(:values, [])
      |> Enum.reduce(attrs, fn
        {field, path}, acc when is_list(path) ->
          keys = Enum.map(path, &Access.key!/1)
          value = get_in(attrs, keys)
          Map.put(acc, field, value)

        {field, func}, acc when is_function(func, 0) ->
          value = func.()
          Map.put(acc, field, value)

        {field, func}, acc when is_function(func, 1) ->
          value = func.(attrs)
          Map.put(acc, field, value)

        {field, value}, acc ->
          Map.put(acc, field, value)
      end)
    end

    def generate_fake_data(attrs, message) do
      fake_data =
        for {name, type, _config} when not is_map_key(attrs, name) <- Metadata.fields(message), into: %{} do
          {name, fake(type)}
        end

      Map.merge(fake_data, attrs)
    end

    def fake({:array, _}), do: []
    def fake(:binary_id), do: UUID.uuid4()
    def fake(Ecto.UUID), do: UUID.uuid4()
    def fake(:id), do: Enum.random(1..1000)
    def fake(:integer), do: Enum.random(1..1000)

    def fake(:float), do: Faker.Commerce.price()
    def fake(:decimal), do: Faker.Commerce.price()

    def fake(:boolean), do: Enum.random([true, false])
    def fake(:string), do: Faker.Company.bullshit()
    def fake(:binary), do: nil

    def fake(:map), do: %{}

    def fake(:utc_datetime), do: Faker.DateTime.between(~U[2000-01-01 00:00:00.000000Z], DateTime.utc_now())
    def fake(:utc_datetime_usec), do: Faker.DateTime.between(~U[2000-01-01 00:00:00.000000Z], DateTime.utc_now())

    def fake(:naive_datetime), do: Faker.DateTime.between(~N[2000-01-01 00:00:00.000000Z], NaiveDateTime.utc_now())
    def fake(:naive_datetime_usec), do: Faker.DateTime.between(~N[2000-01-01 00:00:00.000000Z], NaiveDateTime.utc_now())

    def fake(:date), do: Faker.Date.between(~D[2000-01-01], Date.utc_today())

    def fake(:time), do: nil
    def fake(:time_usec), do: nil

    def fake(:any), do: Faker.Person.suffix()

    def factory_name(message, opts) do
      case Keyword.get(opts, :as, nil) do
        name when is_atom(name) and not is_nil(name) ->
          String.to_atom(to_string(name) <> "_factory")

        _ ->
          message
          |> Module.split()
          |> List.last()
          |> Macro.underscore()
          |> Kernel.<>("_factory")
          |> String.to_atom()
      end
    end

    defp satisfy_dependencies(attrs, opts) do
      opts
      |> Keyword.get(:deps, [])
      |> Enum.reduce(%{}, &dispatch_dependency(&1, &2))
      |> Map.merge(attrs)
    end

    require Logger

    defp dispatch_dependency({key, module}, attrs) when is_atom(module) do
      dispatch_dependency({key, {module, []}}, attrs)
    end

    defp dispatch_dependency({key, {module, opts}}, attrs) when is_atom(module) do
      unless Message.dispatchable?(module) do
        raise Cqrs.Testing.ExMachina.DispatchStrategy.Error,
          message: "#{inspect(module)} is not dispatchable. It can not be used as a factory dependency"
      end

      attrs
      |> populate_data_from_opts(opts)
      |> generate_fake_data(module)
      |> module.new()
      |> module.dispatch(return: :context)
      |> case do
        {:ok, context} ->
          result = DispatchContext.get_last_pipeline(context)
          Map.put(attrs, key, result)

        {:error, context} ->
          raise Error, errors: DispatchContext.errors(context)
      end
    end
  end
end
