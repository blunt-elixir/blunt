if Code.ensure_loaded?(ExMachina) and Code.ensure_loaded?(Faker) do
  defmodule Blunt.Testing.ExMachina.Factory do
    @moduledoc false
    defstruct [:message, values: [], dispatch?: false]

    defmodule Error do
      defexception [:errors]

      def message(%{errors: errors}) do
        inspect(errors)
      end
    end

    alias Blunt.Message
    alias Blunt.Message.Metadata

    alias Blunt.Testing.ExMachina.Values.{
      Constant,
      Lazy,
      Prop
    }

    def build(%__MODULE__{message: message, values: values, dispatch?: dispatch?}, attrs, opts) do
      data = Enum.reduce(values, attrs, &resolve_value/2)

      case Blunt.Behaviour.validate(message, Blunt.Message) do
        {:error, _} ->
          if function_exported?(message, :__struct__, 0) do
            struct!(message, data)
          else
            raise Error, errors: "#{inspect(message)} should be a struct to be used as a factory"
          end

        {:ok, message} ->
          if Keyword.get(opts, :debug, false) do
            IO.inspect(data, label: inspect(message))
          end

          data = populate_missing_props(data, message)

          final_message =
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

          if dispatch?, do: dispatch(final_message, opts), else: final_message
      end
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

        %Prop{field: field, value_path: path} ->
          keys = Enum.map(path, &Access.key/1)
          value = get_in(acc, keys)
          Map.put(acc, field, value)

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
        for {name, type, _config} when not is_map_key(attrs, name) <- Metadata.fields(message), into: %{} do
          {name, fake(type)}
        end

      Map.merge(data, attrs)
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
  end
end
