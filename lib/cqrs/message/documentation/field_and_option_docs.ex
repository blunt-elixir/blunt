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
    base_field_docs(field) <> "\n\n" <> field_hints(field, render_default: false)
  end

  def field_docs(:optional, field) do
    base_field_docs(field) <> "\n\n" <> field_hints(field, render_default: true)
  end

  defp field_hints({_name, type, config}, render_default: render_default) do
    default =
      if render_default do
        value = Keyword.fetch!(config, :default)
        "\t * default value: **#{inspect(value)}**\n\n"
      end

    possible_values =
      if type in [:enum, {:array, :enum}] do
        values =
          Keyword.fetch!(config, :values)
          |> Enum.map(&"**#{inspect(&1)}**")
          |> Enum.join(", ")

        " \t * possible values: #{values}\n"
      end

    to_string(default) <> to_string(possible_values)
  end

  defp base_field_docs({name, type, config}) do
    docs =
      case Keyword.get(config, :desc) do
        nil ->
          nil

        desc ->
          doc =
            desc
            |> String.trim()
            |> String.trim_trailing(".")

          " - #{doc <> ". "}"
      end

    "* **#{name}** *#{inspect(type)}*#{docs}"
  end
end
