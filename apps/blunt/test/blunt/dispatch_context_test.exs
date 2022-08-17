defmodule Blunt.DispatchContextTest do
  use ExUnit.Case
  alias Blunt.DispatchContext

  describe "discarded data" do
    defmodule DiscardedDataCommand do
      use Blunt.Command

      field :name, :string
    end

    defmodule DiscardedDataCommandHandler do
      use Blunt.CommandHandler

      def handle_dispatch(_command, _context), do: :ok
    end

    test "is reset in command and placed in context" do
      {:ok, context} =
        %{name: "chris", dog: "maize"}
        |> DiscardedDataCommand.new()
        |> DiscardedDataCommand.dispatch(return: :context)

      assert %{"dog" => "maize"} = DispatchContext.discarded_data(context)
    end
  end

  defmodule CustomCommand do
    use Blunt.Command

    field :name, :string
    field :dog, :string, required: false
  end

  defmodule CustomCommandHandler do
    use Blunt.CommandHandler

    def handle_dispatch(_command, _context), do: :ok
  end

  defmodule CustomContext do
    use Blunt.BoundedContext

    command CustomCommand
  end

  test "has_user_supplied_field?" do
    {:ok, context} = CustomContext.custom_command([name: "chris"], return: :context)
    assert DispatchContext.has_user_supplied_field?(context, :name)

    {:ok, context} = CustomContext.custom_command([name: "chris", dog: "maize"], return: :context)
    assert DispatchContext.has_user_supplied_field?(context, :name)
    assert DispatchContext.has_user_supplied_field?(context, :dog)
  end
end
