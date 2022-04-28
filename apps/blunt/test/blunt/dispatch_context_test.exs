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

    test "is removed from command and placed in context" do
      {:ok, context} =
        %{name: "chris", dog: "maize"}
        |> DiscardedDataCommand.new()
        |> DiscardedDataCommand.dispatch(return: :context)

      assert %{"dog" => "maize"} = DispatchContext.discarded_data(context)
      assert command = DispatchContext.get_message(context)
      refute Map.has_key?(command, :discarded_data)
    end
  end
end
