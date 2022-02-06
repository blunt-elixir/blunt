defmodule Cqrs.CommandTest do
  use ExUnit.Case, async: true

  alias Cqrs.ExecutionContext
  alias Cqrs.CommandTest.Protocol

  test "dispatch with no handler" do
    alias Protocol.DispatchNoHandler
    alias Cqrs.MessageDispatcher.HandlerProvider.Error

    error = "No CommandHandler found for query: Cqrs.CommandTest.Protocol.DispatchNoHandler"

    assert_raise(Error, error, fn ->
      %{name: "chris"}
      |> DispatchNoHandler.new()
      |> DispatchNoHandler.dispatch()
    end)
  end

  describe "dispatch" do
    alias Protocol.DispatchWithHandler
    alias Cqrs.MessageDispatcher.HandlerProvider.Error

    test "options" do
      options = DispatchWithHandler.__options__() |> Enum.into(%{})

      assert %{
               error_at: [
                 {:type, :enum},
                 {:required, false},
                 {:default, nil},
                 {:values, [:before_dispatch, :handle_authorize, :handle_dispatch]}
               ],
               reply_to: [type: :pid, default: nil, required: true],
               return: [
                 {:type, :enum},
                 {:values, [:context, :response]},
                 {:default, :response},
                 {:required, true}
               ]
             } = options
    end

    test "command requires reply_to option to be set" do
      assert {:error, context} =
               %{name: "chris"}
               |> DispatchWithHandler.new()
               |> DispatchWithHandler.dispatch()

      assert %{errors: [opts: %{reply_to: ["can't be blank"]}]} = context
    end

    test "command requires reply_to option to be set to a valid Pid" do
      assert {:error, context} =
               %{name: "chris"}
               |> DispatchWithHandler.new()
               |> DispatchWithHandler.dispatch(reply_to: "lkajsdf")

      assert [opts: %{reply_to: ["is not a valid Pid"]}] = ExecutionContext.errors(context)
      assert %{errors: [opts: %{reply_to: ["is not a valid Pid"]}]} = context
    end

    test "returns handle_dispatch result by default" do
      assert {:ok, "YO-HOHO"} =
               %{name: "chris"}
               |> DispatchWithHandler.new()
               |> DispatchWithHandler.dispatch(reply_to: self())
    end

    test "returns context if selected in option" do
      assert {:ok, context} =
               %{name: "chris"}
               |> DispatchWithHandler.new()
               |> DispatchWithHandler.dispatch(return: :context, reply_to: self())

      assert %ExecutionContext{errors: [], last_pipeline_step: :handle_dispatch} = context
      assert %{child: %{related: "value"}} = ExecutionContext.get_private(context)

      assert "YO-HOHO" = ExecutionContext.get_last_pipeline(context)
    end
  end

  describe "async dispatch" do
    alias Protocol.DispatchWithHandler

    test "is simple" do
      assert %Task{} = task = %{name: "chris"}
      |> DispatchWithHandler.new()
      |> DispatchWithHandler.dispatch_async(return: :context, reply_to: self())

      assert {:ok, context} = Task.await(task)

      assert %ExecutionContext{errors: [], last_pipeline_step: :handle_dispatch} = context
      assert %{child: %{related: "value"}} = ExecutionContext.get_private(context)

      assert "YO-HOHO" = ExecutionContext.get_last_pipeline(context)
    end
  end

  describe "dispatch error simulations" do
    alias Protocol.DispatchWithHandler

    test "simulate error in before_dispatch" do
      {:error, context} = dispatch(error_at: :before_dispatch)

      assert %{
               errors: [:before_dispatch_error],
               last_pipeline_step: :before_dispatch,
               private: %{}
             } = context

      assert {:error, :before_dispatch_error} == ExecutionContext.get_last_pipeline(context)
    end

    test "simulate error in handle_authorize" do
      {:error, context} = dispatch(error_at: :handle_authorize)

      assert %{
               errors: [:handle_authorize_error],
               last_pipeline_step: :handle_authorize,
               private: %{child: %{related: "value"}}
             } = context

      assert {:error, :handle_authorize_error} == ExecutionContext.get_last_pipeline(context)
    end

    test "simulate error in handle_dispatch" do
      {:error, context} = dispatch(error_at: :handle_dispatch)

      assert %{
               errors: [:handle_dispatch_error],
               last_pipeline_step: :handle_dispatch,
               private: %{child: %{related: "value"}}
             } = context

      assert {:error, :handle_dispatch_error} == ExecutionContext.get_last_pipeline(context)
    end

    defp dispatch(error_at: error_at) do
      opts = [error_at: error_at, return: :context, reply_to: self()]

      %{name: "chris"}
      |> DispatchWithHandler.new()
      |> DispatchWithHandler.dispatch(opts)
    end
  end
end
