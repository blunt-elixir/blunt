defmodule Cqrs.MessageTest.Protocol do
  defmodule Simple do
    use Cqrs.Message

    field :name, :string
  end

  defmodule FieldOptions do
    @moduledoc """
    Hi
    """
    use Cqrs.Message

    field :name, :string, required: true, desc: "your name"
    field :dog, :string, default: "maize", desc: "your dog's name"
    field :gender, :enum, values: [:m, :f], desc: "your gender"
    field :other, {:array, :enum}, values: [:one, :two_three], desc: "just guess"
  end

  defmodule MessageWithInternalField do
    use Cqrs.Message

    internal_field :id, :binary_id, required: true
  end
end
