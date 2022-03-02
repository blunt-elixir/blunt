defmodule Blunt.Data.Factories.Builder.MapBuilder do
  use Blunt.Data.Factories.Builder

  @impl true
  def recognizes?(Map), do: true
  def recognizes?(_), do: false

  @impl true
  def message_fields(_message_module), do: []

  @impl true
  def build(_message_module, data), do: data
end
