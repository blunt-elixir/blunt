defmodule Blunt.Data.Factories.FakeProvider do
  @type field_type :: atom()
  @type validation :: atom()

  @callback fake(field_type(), validation(), keyword()) :: any()

  def fake(type, validation, config) do
    Blunt.Data.Factories.FakeProvider.Default.fake(type, validation, config)
  end
end
