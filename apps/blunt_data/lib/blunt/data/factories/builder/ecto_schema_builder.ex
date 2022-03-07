defmodule Blunt.Data.Factories.Builder.EctoSchemaBuilder do
  use Blunt.Data.Factories.Builder

  @impl true
  def recognizes?(message_module) do
    function_exported?(message_module, :__changeset__, 0)
  end

  @impl true
  def message_fields(message_module) do
    message_module.__changeset__()
    # |> Enum.reject(&match?({_name, {:assoc, _}}, &1))
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
  def build(message_module, data) do
    fields =
      message_module
      |> message_fields()
      |> Enum.map(&elem(&1, 0))

    data =
      data
      |> Map.take(fields)
      |> data_map()

    if function_exported?(message_module, :changeset, 1) do
      message_module
      |> apply(:changeset, [data])
      |> Ecto.Changeset.apply_action!(:insert)
    else
      struct!(message_module, data)
    end
  end

  defp data_map(struct) when is_struct(struct) do
    struct
    |> Map.from_struct()
    |> data_map()
  end

  defp data_map(map) when is_map(map) do
    Enum.into(map, %{}, fn {key, value} -> {key, data_map(value)} end)
  end

  defp data_map(other), do: other
end
