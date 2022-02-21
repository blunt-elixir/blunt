defmodule Cqrs.Message.Documentation.MetadataDocs do
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
      |> Enum.map(fn {name, value} ->
        to_string(name) <> ": " <> inspect(value)
      end)
      |> Enum.join("\n\n")

    ~s[

## Metadata

```
#{metadata}
```
          ]
  end
end
