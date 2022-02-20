defmodule Cqrs.Message.Documentation do
  @moduledoc false
  alias Cqrs.Message.Documentation.{FieldAndOptionDocs, MetadataDocs}

  defmacro generate_module_docs do
    quote do
      {line, moduledoc} = Module.get_attribute(__MODULE__, :moduledoc) || {nil, ""}

      @metadata shortdocs: moduledoc

      field_docs = FieldAndOptionDocs.field_docs(@schema_fields)

      option_docs =
        case Module.get_attribute(__MODULE__, :options) do
          nil -> ""
          options -> FieldAndOptionDocs.option_docs(options)
        end

      metadata_docs = MetadataDocs.generate(@metadata)

      Module.put_attribute(__MODULE__, :moduledoc, {line || 1, moduledoc <> field_docs <> option_docs <> metadata_docs})
    end
  end

  defmacro generate_constructor_docs do
    quote do
      message = __MODULE__ |> Module.split() |> List.last()
      docs = "Safely constructs a `#{inspect(message)}`"
      docs <> "\n\n" <> FieldAndOptionDocs.field_docs(@schema_fields)
    end
  end

  defmacro generate_dispatch_docs do
    quote do
      message = __MODULE__ |> Module.split() |> List.last()
      docs = "Dispatches a validated `#{inspect(message)}`"

      case Module.get_attribute(__MODULE__, :options) do
        nil -> docs
        options -> docs <> "\n\n" <> FieldAndOptionDocs.option_docs(options)
      end
    end
  end
end
