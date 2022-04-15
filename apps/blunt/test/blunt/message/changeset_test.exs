defmodule Blunt.Message.ChangesetTest do
  use ExUnit.Case

  defmodule EmbeddedMessage do
    use Blunt.ValueObject
  end

  defmodule SomeCommand do
    use Blunt.Command
    option :test_option, :boolean
    option :reply_to, :pid
    field :name, :string
    field :msg, EmbeddedMessage

    def handle_validate(changeset, opts) do
      reply_to = Keyword.get(opts, :reply_to)
      send(reply_to, {:opts, opts})
      changeset
    end
  end

  test "works" do
    opts = [test_option: true, reply_to: self()]
    assert {:ok, %SomeCommand{msg: %EmbeddedMessage{}}} = SomeCommand.new(%{name: "John", msg: %{}}, %{}, opts)

    assert_receive {:opts, opts}
    assert true = Keyword.get(opts, :test_option)
  end
end
