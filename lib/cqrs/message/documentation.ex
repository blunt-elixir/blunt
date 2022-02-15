defmodule Cqrs.Message.Documentation do
  @moduledoc false
  alias Cqrs.Message.Documentation

  defmacro generate do
    quote do
      docs = Documentation.all_field_docs(@schema_fields)
      {_line, moduledoc} = Module.get_attribute(__MODULE__, :moduledoc) || {nil, ""}

      File.write!("#{inspect(__MODULE__)}.md", moduledoc <> docs)

      Module.put_attribute(__MODULE__, :moduledoc, {1, docs})
    end
  end

  def all_field_docs(fields) do
    {required, optional} =
      fields
      |> Enum.sort_by(&elem(&1, 0))
      |> Enum.split_with(fn
        {_name, _type, config} -> Keyword.get(config, :required) == true
      end)

    required_fields_section = field_docs_section(required, :required, "required")
    optional_field_section = field_docs_section(optional, :optional, "optional")

    cond do
      required_fields_section == nil and optional_field_section == nil ->
        ""

      true ->
        """

        ## Fields
        #{to_string(required_fields_section) <> "\n" <> to_string(optional_field_section)}
        """
    end
  end

  defp field_docs_section([], _type, _title), do: nil

  defp field_docs_section(fields, type, title) do
    docs = Enum.map(fields, &field_docs(type, &1))

    """

    ### #{title}

    #{Enum.join(docs, "\n")}
    """
  end

  defp field_docs(:required, field) do
    base_field_docs(field)
  end

  defp field_docs(:optional, field) do
    base_field_docs(field) <> optional_field_docs(field)
  end

  defp optional_field_docs({_name, type, config}) when type in [:enum, {:array, :enum}] do
    default = Keyword.fetch!(config, :default)
    possible_values = Keyword.fetch!(config, :values) |> inspect()

    """
    \n
    \t * default value: `#{inspect(default)}`
    \n
    \t * possible values: `#{possible_values}`
    """
  end

  defp optional_field_docs({_name, _type, config}) do
    default = Keyword.fetch!(config, :default)

    """
    \n
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
end
