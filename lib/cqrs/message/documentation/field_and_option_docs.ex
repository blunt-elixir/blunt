defmodule Cqrs.Message.Documentation.FieldAndOptionDocs do
  def field_docs(fields), do: generate("Fields", fields)
  def option_docs(options), do: generate("Options", options)

  defp generate(title, fields) do
    {required, optional} =
      fields
      |> Enum.sort_by(&elem(&1, 0))
      |> Enum.split_with(fn
        {_name, _type, config} -> Keyword.get(config, :required) == true
      end)

    required_fields_section = docs_section(required, :required, "required")
    optional_field_section = docs_section(optional, :optional, "optional")

    cond do
      required_fields_section == nil and optional_field_section == nil ->
        ""

      true ->
        """

        ## #{title}
        #{to_string(required_fields_section) <> "\n" <> to_string(optional_field_section)}
        """
    end
  end

  defp docs_section([], _type, _title), do: nil

  defp docs_section(fields, type, title) do
    docs = Enum.map(fields, &field_docs(type, &1))

    """

    ### #{title}

    #{Enum.join(docs, "\n")}
    """
  end

  def field_docs(:required, field) do
    base_field_docs(field) <> notes(field)
  end

  def field_docs(:optional, field) do
    base_field_docs(field) <> optional_field_docs(field) <> notes(field)
  end

  defp optional_field_docs({_name, type, config}) when type in [:enum, {:array, :enum}] do
    default = Keyword.fetch!(config, :default)
    possible_values = Keyword.fetch!(config, :values) |> inspect()

    """

    \t * default value: `#{inspect(default)}`

    \t * possible values: `#{possible_values}`
    """
  end

  defp optional_field_docs({_name, _type, config}) do
    default = Keyword.fetch!(config, :default)

    """

    \t * default value: `#{inspect(default)}`
    """
  end

  defp base_field_docs({name, type, config}) do
    docs =
      case Keyword.get(config, :desc) do
        nil -> nil
        desc -> " - #{desc}"
      end

    "* `#{name}` _#{inspect(type)}_#{docs}"
  end

  defp notes({_name, _type, config}) do
    case Keyword.get(config, :notes) do
      nil ->
        ""

      notes ->
        notes =
          notes
          |> String.split("\n")
          |> Enum.reject(&(&1 == ""))
          |> Enum.map(fn line -> "\t" <> String.trim(line) end)
          |> Enum.join("\n\n")

        "\n" <> notes
    end
  end
end
