defmodule Cqrs.MessageTest.Protocol do
  defmodule Simple do
    use Cqrs.Message

    field :name, :string
  end

  defmodule FieldOptions do
    use Cqrs.Message

    field :name, :string, required: true
    field :dog, :string, default: "maize"
    field :gender, :enum, values: [:m, :f]
  end
end
