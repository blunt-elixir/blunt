defmodule Blunt.Testing.Factories.FakeProvider do
  @moduledoc false
  @behaviour Blunt.Data.Factories.FakeProvider

  alias Blunt.Message.Schema.FieldProvider

  @doc false
  @impl true
  def fake(type, validation, config) do
    FieldProvider.fake(type, config, validation: validation)
  end
end
