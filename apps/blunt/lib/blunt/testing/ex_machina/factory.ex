if Code.ensure_loaded?(ExMachina) and Code.ensure_loaded?(Faker) do
  defmodule Blunt.Testing.ExMachina.Factory do
    @moduledoc false

    defmodule Error do
      defexception [:errors]

      def message(%{errors: errors}) do
        inspect(errors)
      end
    end

    @derive {Inspect, except: [:dispatch?]}
    defstruct [:message, values: [], dispatch?: false]

    alias Blunt.Message
    alias Blunt.Testing.ExMachina.Values.{Constant, Lazy, Prop}

    def build(%__MODULE__{message: message, values: values} = factory, attrs, opts) do
      if Keyword.get(opts, :debug, false) do
        IO.inspect(factory)
      end

      data = Enum.reduce(values, attrs, &resolve_value/2)

      case Blunt.Behaviour.validate(message, Blunt.Message) do
        {:error, _} -> build_struct(message, data)
        {:ok, _} -> build_blunt_message(factory, data, opts)
      end
    end

    defp build_struct(message, data) do
      unless function_exported?(message, :__struct__, 0) do
        raise Error, errors: "#{inspect(message)} should be a struct to be used as a factory"
      end

      struct!(message, data)
    end

    defp build_blunt_message(%{message: message, dispatch?: dispatch?}, data, opts) do
      final_message =
        data
        |> populate_missing_props(message)
        |> message.new()
        |> case do
          {:ok, message, _discarded_data} ->
            message

          {:ok, message} ->
            message

          {:error, errors} ->
            raise Error, errors: errors

          message ->
            message
        end

      if dispatch?, do: dispatch(final_message, opts), else: final_message
    end

    defp dispatch(%{__struct__: module} = message, opts) do
      unless Message.dispatchable?(message) do
        message
      else
        opts = Keyword.put(opts, :return, :response)

        case module.dispatch({:ok, message, %{}}, opts) do
          {:ok, value} -> value
          {:error, errors} -> raise Error, errors: errors
        end
      end
    end

    defp resolve_value(value, acc) do
      case value do
        %Constant{field: field, value: value} ->
          Map.put(acc, field, value)

        %Prop{field: field, value_path_or_func: path} when is_list(path) ->
          keys = Enum.map(path, &Access.key/1)
          value = get_in(acc, keys)
          Map.put(acc, field, value)

        %Prop{field: field, value_path_or_func: func} when is_function(func, 0) ->
          Map.put(acc, field, func.())

        %Prop{field: field, value_path_or_func: func} when is_function(func, 1) ->
          Map.put(acc, field, func.(acc))

        %Lazy{field: field, factory: factory} ->
          case Map.get(acc, field) do
            nil ->
              value = build(factory, acc, [])
              Map.put(acc, field, value)

            _value ->
              acc
          end
      end
    end

    defp populate_missing_props(attrs, message) do
      data =
        for {name, type, config} when not is_map_key(attrs, name) <- Message.Metadata.fields(message), into: %{} do
          {name, fake(type, config)}
        end

      Map.merge(data, attrs)
    end

    def fake(type, config) do
      case type do
        :any -> Faker.Person.suffix()
        :binary -> nil
        :boolean -> Enum.random([true, false])
        :date -> Faker.Date.between(~D[2000-01-01], Date.utc_today())
        :decimal -> Faker.Commerce.price()
        :float -> Faker.Commerce.price()
        :id -> Enum.random(1..1000)
        :integer -> Enum.random(1..1000)
        :map -> %{}
        :naive_datetime -> Faker.DateTime.between(~N[2000-01-01 00:00:00.000000Z], NaiveDateTime.utc_now())
        :naive_datetime_usec -> Faker.DateTime.between(~N[2000-01-01 00:00:00.000000Z], NaiveDateTime.utc_now())
        :string -> Faker.Company.bullshit()
        :time -> nil
        :time_usec -> nil
        :utc_datetime -> Faker.DateTime.between(~U[2000-01-01 00:00:00.000000Z], DateTime.utc_now())
        :utc_datetime_usec -> Faker.DateTime.between(~U[2000-01-01 00:00:00.000000Z], DateTime.utc_now())
        {:array, type} -> [fake(type, config)]
        binary_id when binary_id in [:binary_id, Ecto.UUID] -> UUID.uuid4()
        other -> other_fake(other, config)
      end
    end

    defp other_fake(enum, config) when enum in [:enum, Ecto.Enum] do
      values = Keyword.fetch!(config, :values)
      Enum.random(values)
    end
  end
end
