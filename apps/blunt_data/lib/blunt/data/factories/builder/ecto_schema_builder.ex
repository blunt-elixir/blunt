defmodule Blunt.Data.Factories.Builder.EctoSchemaBuilder do
  use Blunt.Data.Factories.Builder

  @impl true
  def recognizes?(message_module) do
    function_exported?(message_module, :__changeset__, 0)
  end

  @impl true
  def message_fields(message_module) do
    message_module.__changeset__()
    |> Enum.reject(&match?({_name, {:assoc, _}}, &1))
    |> Enum.reject(&match?({:inserted_at, _}, &1))
    |> Enum.reject(&match?({:updated_at, _}, &1))
    |> Enum.map(fn
      {name, {:parameterized, Ecto.Enum, config}} ->
        values = Map.get(config, :on_dump) |> Map.keys()
        {name, :enum, [values: values]}

      {name, type} ->
        {name, type, []}
    end)
  end

  @impl true
  def build(message_module, data), do: struct!(message_module, data)
end
