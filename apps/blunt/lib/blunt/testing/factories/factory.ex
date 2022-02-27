if Code.ensure_loaded?(ExMachina) and Code.ensure_loaded?(Faker) do
  defmodule Blunt.Testing.Factories.Factory do
    @moduledoc false

    defmodule Error do
      defexception [:errors]

      def message(%{errors: errors}) do
        inspect(errors)
      end
    end

    defmacrop debug(value, label, opts) do
      quote bind_quoted: [label: label, value: value, opts: opts] do
        case Keyword.get(opts, :debug, false) do
          true ->
            name = Keyword.fetch!(opts, :name)
            message_name = Keyword.fetch!(opts, :message_name)
            title = IO.ANSI.format([:blue, "blunt", " - ", :blue, name, :reset, " (", :light_black, message_name, ")"])

            IO.inspect(value, label: "[#{title} #{label}]", syntax_colors: [string: :yellow])

          _ ->
            value
        end
      end
    end

    @derive {Inspect, only: [:name, :message]}
    defstruct [:name, :message, :message_name, values: [], dispatch?: false]

    def new(name, message, values, dispatch? \\ false) do
      message_name = message |> Module.split() |> List.last() |> to_string()

      %__MODULE__{
        name: String.trim_trailing(to_string(name), "_factory"),
        message: message,
        message_name: message_name,
        values: values,
        dispatch?: dispatch?
      }
    end

    alias Blunt.Message
    alias Blunt.Testing.Factories.Values.{Constant, Data, Prop}

    def build(%__MODULE__{message: message, values: values} = factory, attrs, opts) do
      opts =
        factory
        |> Map.take([:name, :message_name])
        |> Enum.to_list()
        |> Keyword.merge(opts)

      debug(factory, IO.ANSI.format([:green, :bright, "build"]), opts)
      debug(attrs, IO.ANSI.format([:light_blue, "input"]), opts)

      data = Enum.reduce(values, attrs, &resolve_value(&1, &2, opts))

      built_message =
        case Blunt.Behaviour.validate(message, Blunt.Message) do
          {:error, _} -> build_struct(message, data, opts)
          {:ok, _} -> build_blunt_message(factory, data, opts)
        end

      debug(built_message, IO.ANSI.format([:green, :bright, "deliver"]), opts)
    end

    defp build_struct(message, data, opts) do
      unless function_exported?(message, :__struct__, 0) do
        raise Error, errors: "#{inspect(message)} should be a struct to be used as a factory"
      end

      if function_exported?(message, :__changeset__, 0) do
        message_fields =
          message.__changeset__()
          |> Enum.reject(&match?({_name, {:assoc, _}}, &1))
          |> Enum.reject(&match?({:inserted_at, _}, &1))
          |> Enum.reject(&match?({:updated_at, _}, &1))
          |> Enum.map(fn
            {name, {:parameterized, Ecto.Enum, config}} ->
              values = Map.get(config, :on_dump) |> Map.keys()
              {name, :enum, [values: values]}

            {name, type} ->
              {name, type, []}
          end)

        data = populate_missing_props(data, message_fields, opts)
        struct!(message, data)
      else
        struct!(message, data)
      end
    end

    defp build_blunt_message(%{message: message, dispatch?: dispatch?}, data, opts) do
      message_fields = Message.Metadata.fields(message)

      final_message =
        data
        |> populate_missing_props(message_fields, opts)
        |> message.new()
        |> case do
          {:ok, message, _discarded_data} ->
            message

          other ->
            other
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

    defp resolve_value(value, acc, opts) do
      log_value = fn value, field, lazy, type ->
        field = IO.ANSI.format([:blue, :bright, to_string(field)])
        type_prefix = if lazy, do: "lazy ", else: ""
        debug(value, "#{type_prefix}#{type} #{field}", opts)
      end

      case value do
        nil ->
          acc

        %Constant{field: field, value: value} ->
          value = log_value.(value, field, false, "const")
          Map.put(acc, field, value)

        %Prop{field: field, value_path_or_func: path, lazy: lazy} when is_list(path) ->
          if not lazy or (lazy and not Map.has_key?(acc, field)) do
            keys = Enum.map(path, &Access.key/1)
            value = get_in(acc, keys) |> log_value.(field, lazy, "prop")
            Map.put(acc, field, value)
          else
            acc
          end

        %Prop{field: field, value_path_or_func: func, lazy: lazy} when is_function(func, 0) ->
          if not lazy or (lazy and not Map.has_key?(acc, field)) do
            value = func.() |> log_value.(field, lazy, "prop")
            Map.put(acc, field, value)
          else
            acc
          end

        %Prop{field: field, value_path_or_func: func, lazy: lazy} when is_function(func, 1) ->
          if not lazy or (lazy and not Map.has_key?(acc, field)) do
            value = func.(acc) |> log_value.(field, lazy, "prop")
            Map.put(acc, field, value)
          else
            acc
          end

        %Data{field: field, factory: factory, lazy: lazy} ->
          if not lazy or (lazy and not Map.has_key?(acc, field)) do
            opts = Keyword.put(opts, :debug, false)
            value = build(factory, acc, opts) |> log_value.(field, lazy, "data")
            Map.put(acc, field, value)
          else
            acc
          end
      end
    end

    defp populate_missing_props(attrs, message_fields, opts) do
      data =
        for {field, type, config} when not is_map_key(attrs, field) <- message_fields, into: %{} do
          value = fake(type, config)

          debug(value, IO.ANSI.format(["faked ", :blue, :bright, to_string(field), :reset]), opts)

          {field, value}
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
        :id -> Enum.random(1..100_000)
        :integer -> Enum.random(1..100_000)
        :map -> %{}
        :naive_datetime -> Faker.DateTime.between(~N[2000-01-01 00:00:00.000000Z], NaiveDateTime.utc_now())
        :naive_datetime_usec -> Faker.DateTime.between(~N[2000-01-01 00:00:00.000000Z], NaiveDateTime.utc_now())
        :string -> Faker.Company.bullshit() <> " " <> Faker.Commerce.product_name()
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

    defp other_fake({:embed, %Ecto.Embedded{cardinality: :one}}, _config) do
      nil
    end
  end
end
