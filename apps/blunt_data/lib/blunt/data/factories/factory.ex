defmodule Blunt.Data.Factories.Factory do
  @moduledoc false

  alias IO.ANSI

  defmodule Error do
    defexception [:errors]

    def message(%{errors: errors}) do
      inspect(errors)
    end
  end

  @derive {Inspect, only: [:name, :message, :operation]}
  defstruct [
    :name,
    :message,
    :message_name,
    :final_message,
    :fields,
    :field_validations,
    :active_builder,
    :fake_provider,
    :factory_module,
    operation: :build,
    input: %{},
    data: %{},
    values: [],
    builders: [],
    opts: []
  ]

  alias Blunt.Data.Factories.{Builder, Value, Values}

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
            active_builder: active_builder,
            field_validations: field_validations
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
           operation: operation,
           active_builder: builder,
           fake_provider: fake_provider,
           factory_module: factory_module,
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

    final_message =
      case builder.build(message, Map.merge(data, faked_data)) do
        {:ok, final_message} -> final_message
        final_message -> final_message
      end

    final_message =
      case operation do
        :build ->
          final_message

        :builder_dispatch ->
          builder.dispatch(final_message)

        operation ->
          case apply(factory_module, operation, [final_message]) do
            {:ok, result} -> result
            other -> other
          end
      end

    %{factory | final_message: final_message}
  end

  defp normalize(%{name: name, message: message, input: input, data: data, opts: opts, values: values} = factory) do
    name = String.trim_trailing(to_string(name), "_factory")
    message_name = message |> Module.split() |> List.last() |> to_string()
    opts = Keyword.merge(opts, name: name, message_name: message_name)

    # put defaults at the end of the values.
    {defaults, values} = Enum.split_with(values, &match?(%Values.Defaults{}, &1))

    # Allow turning on factory debug via input: %{debug_factory: true}
    default_debug = Keyword.get(opts, :debug, false)
    {debug, input} = Map.pop(input || %{}, :debug_factory, default_debug)
    opts = Keyword.put(opts, :debug, debug)

    %{
      factory
      | name: name,
        message_name: message_name,
        input: input,
        data: data || %{},
        opts: opts,
        values: values ++ defaults
    }
  end

  defp evaluate_values(%{input: input, values: values} = factory) do
    data = Enum.reduce(values, input, &Value.evaluate(&1, &2, factory))
    %{factory | data: data}
  end

  def log_value(%__MODULE__{opts: opts}, value, field, lazy, type) do
    field = ANSI.format([:blue, :bright, to_string(field)])
    type_prefix = if lazy, do: "lazy ", else: ""
    debug(value, "#{type_prefix}#{type} #{field}", opts)
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
