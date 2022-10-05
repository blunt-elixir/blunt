defmodule Types.Json do
  @moduledoc false
  use Absinthe.Schema.Notation
  alias Absinthe.Blueprint.Input.{Null, String}

  scalar :json, name: "Json" do
    description("""
    The `Json` scalar type represents arbitrary json string data, represented as UTF-8
    character sequences. The Json type is most often used to represent a free-form
    human-readable json string.
    """)

    serialize(&encode/1)
    parse(&decode/1)
  end

  defp decode(%String{value: value}) do
    case Jason.decode(value) do
      {:ok, result} -> {:ok, result}
      _ -> :error
    end
  end

  defp decode(%Null{}), do: {:ok, nil}
  defp decode(_), do: :error

  defp encode(value), do: value
end
