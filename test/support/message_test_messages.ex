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

  defmodule MessageOptions do
    use Cqrs.Message

    option :debug, :boolean, default: false
    option :audit, :boolean, default: true
  end

  defmodule DispatchNoHandler do
    use Cqrs.Message

    field :name, :string, required: true
    field :dog, :string, default: "maize"
    field :gender, :enum, values: [:m, :f]
  end

  defmodule DispatchWithHandler do
    use Cqrs.Message

    field :name, :string, required: true
    field :dog, :string, default: "maize"
    field :gender, :enum, values: [:m, :f]

    option :error_at, :enum, values: [:before_dispatch, :handle_authorize, :handle_dispatch]
  end
end
