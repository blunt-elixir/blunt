defmodule Blunt.Data.Factories.Builder.StructBuilder do
  use Blunt.Data.Factories.Builder

  @impl true
  def recognizes?(message_module) do
    function_exported?(message_module, :__struct__, 0)
  end

  @impl true
  def message_fields(message_module) do
    message_module
    |> struct()
    |> Map.keys()
    |> List.delete(:__struct__)
    |> Enum.map(fn key -> {key, :string, []} end)
  end

  @impl true
  def build(message_module, data) do
    keys =
      message_module
      |> struct()
      |> Map.keys()

    struct!(message_module, Map.take(data, keys))
  end
end
