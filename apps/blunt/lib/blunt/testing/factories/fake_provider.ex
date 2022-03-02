defmodule Blunt.Testing.Factories.FakeProvider do
  @moduledoc false
  @behaviour Blunt.Data.Factories.FakeProvider

  alias Blunt.Message.Schema.FieldProvider

  @doc false
  @impl true
  def fake(type, config, opts \\ []) do
    FieldProvider.fake(type, config, opts)
  end
end
