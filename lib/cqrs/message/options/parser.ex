defmodule Cqrs.Message.Options.Parser do
  alias Cqrs.Message.{Changeset, Metadata}

  def parse_message_opts(message_module, opts) do
    message_opts = Metadata.get(message_module, :options, [])

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
        {:ok, Keyword.merge(unparsed, parsed)}

      {:error, errors} ->
        {:error, errors}
    end
  end

  defp parse_option({name, _type, config}, provided_opts) do
    default = Keyword.fetch!(config, :default)
    {name, Keyword.get(provided_opts, name, default)}
  end

  defp validate_options(parsed_opts, supported_opts) do
    required =
      supported_opts
      |> Enum.filter(fn {_, _type, config} -> Keyword.fetch!(config, :required) == true end)
      |> Enum.map(&elem(&1, 0))
      |> Enum.uniq()

    data = %{}

    types =
      Enum.into(supported_opts, %{}, fn {name, type, config} ->
        {name, ecto_type(type, config)}
      end)

    params = Enum.into(parsed_opts, %{})

    changeset =
      {data, types}
      |> Ecto.Changeset.cast(params, Map.keys(types))
      |> Ecto.Changeset.validate_required(required)

    case changeset do
      %{valid?: false} ->
        {:error, Changeset.format_errors(changeset)}

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
