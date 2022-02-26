defmodule Blunt.CustomDispatchStrategyTest do
  use ExUnit.Case, async: false

  alias Blunt.DispatchContext, as: Context
  alias Blunt.{Command, DispatchStrategy, CustomDispatchStrategy}

  setup do
    Application.put_env(:blunt, :dispatch_strategy, CustomDispatchStrategy)

    on_exit(fn ->
      Application.put_env(:blunt, :dispatch_strategy, DispatchStrategy.Default)
    end)
  end

  defmodule CreatePerson do
    use Blunt.Command

    field :name, :string
    field :id, :binary_id, required: false

    def after_validate(command),
      do: %{command | id: UUID.uuid4()}
  end

  defmodule CreatePersonPipeline do
    use Blunt.CustomDispatchStrategy.CustomCommandPipeline

    @impl true
    def before_dispatch(_command, context) do
      {:ok, context}
    end

    @impl true
    def handle_authorize(_user, _command, context) do
      {:ok, context}
    end

    @impl true
    def handle_dispatch(_command, _context) do
      {:ok, :success!}
    end
  end

  test "dispatch with custom strategy" do
    assert {:ok, :success!} =
             %{name: "chris"}
             |> CreatePerson.new()
             |> CreatePerson.dispatch()
  end

  test "dispatch and validate context with custom strategy" do
    assert {:ok, context} =
             %{name: "chris"}
             |> CreatePerson.new()
             |> CreatePerson.dispatch(return: :context)

    assert %{before_dispatch: :ok, handle_authorize: :ok, handle_dispatch: :success!} = Context.get_pipeline(context)

    assert :success! == Command.results(context)
  end
end
