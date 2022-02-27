defmodule Blunt.Message.Documentation.MetadataDocs do
  def generate(metadata) do
    metadata
    |> List.flatten()
    |> Keyword.drop([:dispatchable?, :message_type, :primary_key, :schema_fields, :shortdoc])
    |> create_docs_section()
  end

  defp create_docs_section([]), do: ""

  defp create_docs_section(metadata) do
    metadata =
      metadata
      |> Enum.map(&metadata_value/1)
      |> Enum.join("\n\n")

    ~s[
## Metadata

#{metadata}

]
  end

  defp metadata_value({name, value}) do
    ~s(
### #{name}

#{inspect_value(value)}
)
  end

  defp inspect_value(list) when is_list(list) do
    if Keyword.keyword?(list) do
      Enum.map(list, fn {name, value} ->
        """
        * **#{name}** - `#{inspect(value, pretty: true)}`
        """
      end)
      |> Enum.join("\n")
    else
      "`#{inspect(list, pretty: true)}`"
    end
  end

  defp inspect_value(value) do
    "`#{inspect(value, pretty: true)}`"
  end
end
