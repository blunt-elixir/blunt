defmodule Blunt.Testing.Factories.Builder.BluntMessageBuilder do
  @moduledoc false
  @behaviour Blunt.Data.Factories.Builder

  defmodule Error do
    defexception [:errors]

    def message(%{errors: errors}) do
      inspect(errors)
    end
  end

  alias Blunt.Message.Metadata
  alias Blunt.{Behaviour, Message}

  @impl true
  def recognizes?(message_module) do
    Behaviour.is_valid?(message_module, Message)
  end

  @impl true
  def message_fields(message_module),
    do: Metadata.fields(message_module)

  @impl true
  def field_validations(message_module),
    do: Metadata.field_validations(message_module)

  @impl true
  def build(message_module, data) do
    case message_module.new(data) do
      {:ok, message} ->
        normalize_internal_map_fields(message)

      other ->
        other
    end
  end

  @impl true
  def dispatch({:error, _} = message), do: message

  @impl true
  def dispatch(%{__struct__: module} = message) do
    unless Message.dispatchable?(message) do
      message
    else
      case module.dispatch({:ok, message, %{}}, return: :response) do
        {:ok, value} -> value
        {:error, errors} -> {:error, %Error{errors: errors}}
      end
    end
  end

  defp normalize_internal_map_fields(%{__struct__: message_module} = message) do
    internal_fields =
      Metadata.fields(message_module, :internal)
      |> Enum.filter(fn {_name, type, _opts} -> type == :map end)
      |> Enum.map(&elem(&1, 0))

    fields =
      message
      |> Map.from_struct()
      |> Enum.into(%{}, fn {key, value} ->
        case {Enum.member?(internal_fields, key), value} do
          {true, value} when is_map(value) ->
            value = atomize(value)
            {key, value}

          _ ->
            {key, value}
        end
      end)

    struct!(message_module, fields)
  end

  defp atomize(list) when is_list(list), do: Enum.map(list, &atomize(&1))

  defp atomize(map) when is_map(map) do
    Enum.into(map, %{}, fn {key, value} -> {String.to_atom(key), atomize(value)} end)
  end

  defp atomize(other), do: other
end
