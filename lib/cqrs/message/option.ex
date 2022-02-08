defmodule Cqrs.Message.Option do
  @moduledoc false

  defmodule Error do
    defexception [:message]
  end

  require Logger

  alias Cqrs.Message.Changeset, as: MessageChangeset

  def record(name, type, opts) do
    quote do
      opts =
        unquote(opts)
        |> Keyword.put_new(:default, nil)
        |> Keyword.put_new(:required, false)
        |> Keyword.put(:type, unquote(type))

      @options {unquote(name), opts}
    end
  end

  def return_option do
    values = [:context, :response]

    value = Application.get_env(:cqrs, :dispatch_return, :response)

    unless value in values do
      raise Error,
        message:
          "Invalid :cqrs, :dispatch_return value: `#{value}`. Value must be one of the following: #{inspect(values)}"
    end

    {:return, [type: :enum, values: values, default: value, required: true]}
  end

  def parse_message_opts(message_module, opts) do
    message_opts = message_module.__options__()

    %{parsed: parsed, unparsed: unparsed} =
      Enum.reduce(
        message_opts,
        %{parsed: [], unparsed: opts},
        fn current_option, acc ->
          {name, value} = parse_option(current_option, acc.unparsed)
          %{acc | parsed: [{name, value} | acc.parsed], unparsed: Keyword.delete(acc.unparsed, name)}
        end
      )

    case validate_options(parsed, message_opts) do
      {:ok, parsed} ->
        {:ok, message_opts, Keyword.merge(unparsed, parsed)}

      {:error, errors} ->
        {:error, errors}
    end
  end

  defp parse_option({name, config}, provided_opts) do
    default = Keyword.fetch!(config, :default)
    {name, Keyword.get(provided_opts, name, default)}
  end

  defp validate_options(parsed_opts, supported_opts) do
    required =
      supported_opts
      |> Keyword.filter(fn {_, config} -> Keyword.fetch!(config, :required) == true end)
      |> Keyword.keys()
      |> Enum.uniq()

    data = %{}

    types =
      Enum.into(supported_opts, %{}, fn {name, config} ->
        type = Keyword.fetch!(config, :type)
        {name, ecto_type(type, config)}
      end)

    params = Enum.into(parsed_opts, %{})

    changeset =
      {data, types}
      |> Ecto.Changeset.cast(params, Map.keys(types))
      |> Ecto.Changeset.validate_required(required)

    case changeset do
      %{valid?: false} ->
        {:error, MessageChangeset.format_errors(changeset)}

      %{valid?: true} = changset ->
        validated =
          changset
          |> Ecto.Changeset.apply_changes()
          |> Map.to_list()

        {:ok, validated}
    end
  end

  [
    integer: :integer,
    float: :float,
    boolean: :boolean,
    string: :string,
    map: :map,
    binary: :binary,
    decimal: :decimal,
    id: :id,
    binary_id: Ecto.UUID,
    utc_datetime: :utc_datetime,
    naive_datetime: :naive_datetime,
    date: :date,
    time: :time,
    any: :any,
    utc_datetime_usec: :utc_datetime_usec,
    naive_datetime_usec: :naive_datetime_usec,
    time_usec: :time_usec
  ]
  |> Enum.map(fn {type_hint, ecto_type} ->
    def ecto_type(unquote(type_hint), _config), do: unquote(ecto_type)
    def ecto_type({:array, unquote(type_hint)}, _config), do: {:array, unquote(ecto_type)}
    def ecto_type({:map, unquote(type_hint)}, _config), do: {:map, unquote(ecto_type)}
  end)

  def ecto_type(:pid, _config), do: Cqrs.Message.Type.Pid

  def ecto_type(:enum, config) do
    {:parameterized, Ecto.Enum, Ecto.Enum.init(values: Keyword.get(config, :values))}
  end

  def ecto_type({:array, :enum}, config) do
    {:parameterized, {:array, Ecto.Enum}, Ecto.Enum.init(values: Keyword.get(config, :values))}
  end
end
