defmodule Blunt.Data.Factories.Factory do
  @moduledoc false

  alias IO.ANSI

  defmodule Error do
    defexception [:errors]

    def message(%{errors: errors}) do
      inspect(errors)
    end
  end

  @derive {Inspect, only: [:name, :message]}
  defstruct [
    :name,
    :message,
    :message_name,
    :final_message,
    :fields,
    :field_validations,
    :active_builder,
    :fake_provider,
    input: %{},
    data: %{},
    values: [],
    builders: [],
    dispatch?: false,
    opts: []
  ]

  alias Blunt.Data.Factories.Builder
  alias Blunt.Data.Factories.Values.{Constant, Data, Prop}

  def build(%__MODULE__{} = factory) do
    %{final_message: final_message} =
      factory
      |> normalize()
      |> debug(:self)
      |> init_builder()
      |> evaluate_values()
      |> build_final_message()
      |> debug(:final_message)

    final_message
  end

  defp init_builder(%{builders: builders, message: message} = factory) do
    case Enum.find(builders, & &1.recognizes?(message)) do
      nil ->
        raise Builder.NoBuilderError, message: "no builder found for '#{inspect(message)}'"

      active_builder ->
        fields = active_builder.message_fields(message)
        field_validations = active_builder.field_validations(message)

        factory = %{
          factory
          | fields: fields,
            field_validations: field_validations,
            active_builder: active_builder
        }

        debug(factory, :active_builder)
    end
  end

  defp build_final_message(
         %{
           opts: opts,
           data: data,
           fields: fields,
           message: message,
           dispatch?: dispatch?,
           active_builder: builder,
           fake_provider: fake_provider,
           field_validations: field_validations
         } = factory
       ) do
    faked_data =
      for {field, type, config} when not is_map_key(data, field) <- fields, into: %{} do
        validation = Keyword.get(field_validations, field, :none)
        value = fake_provider.fake(type, validation, config)

        debug(value, ANSI.format(["faked ", :blue, :bright, to_string(field), :reset]), opts)

        {field, value}
      end

    final_message = builder.build(message, Map.merge(data, faked_data))
    final_message = if dispatch?, do: builder.dispatch(final_message), else: final_message

    %{factory | final_message: final_message}
  end

  defp normalize(%{name: name, message: message, input: input, data: data, opts: opts} = factory) do
    name = String.trim_trailing(to_string(name), "_factory")
    message_name = message |> Module.split() |> List.last() |> to_string()
    opts = Keyword.merge(opts, name: name, message_name: message_name)

    %{
      factory
      | name: name,
        message_name: message_name,
        input: input || %{},
        data: data || %{},
        opts: opts
    }
  end

  defp evaluate_values(%{input: input, values: values} = factory) do
    data = Enum.reduce(values, input, &evaluate_value(&1, &2, factory))
    %{factory | data: data}
  end

  defp evaluate_value(value, acc, %{opts: opts} = current_factory) do
    log_value = fn value, field, lazy, type ->
      field = ANSI.format([:blue, :bright, to_string(field)])
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
          factory_config =
            factory
            |> Map.put(:input, acc)
            |> Map.put(:opts, current_factory.opts)
            |> Map.put(:builders, current_factory.builders)
            |> Map.put(:fake_provider, current_factory.fake_provider)

          value =
            __MODULE__
            |> struct!(factory_config)
            |> build()
            |> log_value.(field, lazy, "data")

          Map.put(acc, field, value)
        else
          acc
        end
    end
  end

  defp debug(%{opts: opts, input: input} = factory, :self) do
    label = ANSI.format([:green, "build"])
    debug(factory, label, opts)
    label = ANSI.format([:light_blue, "input"])
    debug(input, label, opts)
    factory
  end

  defp debug(%{final_message: final_message, opts: opts} = factory, :final_message) do
    label = ANSI.format([:green, "deliver"])
    debug(final_message, label, opts)
    factory
  end

  defp debug(%{active_builder: builder, opts: opts} = factory, :active_builder) do
    label = ANSI.format([:light_blue, "builder"])
    debug(builder, label, opts)
    factory
  end

  @colors [
    reset: [:reset, :yellow],
    atom: :cyan,
    string: :green,
    list: :default_color,
    boolean: :magenta,
    nil: :magenta,
    tuple: :default_color,
    binary: :default_color,
    map: :default_color
  ]

  defp debug(value, label, opts) do
    case Keyword.get(opts, :debug, false) do
      true ->
        name = Keyword.fetch!(opts, :name)
        message_name = Keyword.fetch!(opts, :message_name)

        title =
          ANSI.format([
            :blue,
            "blunt",
            " - ",
            :blue,
            name,
            :reset,
            " (",
            :light_black,
            message_name,
            ")"
          ])

        IO.inspect(value, label: "[#{title} #{label}]", syntax_colors: @colors)

      _ ->
        value
    end
  end
end
