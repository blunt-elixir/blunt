defmodule Blunt.MessageTest.Protocol do
  defmodule Simple do
    use Blunt.Message

    field :name, :string
  end

  defmodule FieldOptions do
    @moduledoc """
    Hi
    """
    use Blunt.Message

    field :name, :string, required: true
    field :dog, :string, default: "maize"
    field :gender, :enum, values: [:m, :f]
    field :today, :date, autogenerate: {__MODULE__, :today, []}

    def today do
      Date.utc_today()
    end
  end

  defmodule MessageWithInternalField do
    use Blunt.Message

    internal_field :id, :binary_id, required: true
  end
end
