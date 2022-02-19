defmodule Cqrs.Message.Documentation do
  @moduledoc false
  alias Cqrs.Message.Documentation.FieldDocs

  defmacro generate do
    quote do
      docs = FieldDocs.generate(@schema_fields)
      {_line, moduledoc} = Module.get_attribute(__MODULE__, :moduledoc) || {nil, ""}

      File.write!("tmp/#{inspect(__MODULE__)}.md", moduledoc <> docs)

      Module.put_attribute(__MODULE__, :moduledoc, {1, docs})
    end
  end
end
