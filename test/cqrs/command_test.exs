defmodule Cqrs.CommandTest do
  use ExUnit.Case, async: true

  alias Cqrs.CommandTest.Protocol
  alias Cqrs.{Command, DispatchContext, DispatchError}

  test "command options" do
    alias Protocol.CommandOptions
    options = CommandOptions.__options__() |> Enum.into(%{})

    assert %{
             audit: [{:type, :boolean}, {:required, false}, {:default, true}],
             debug: [{:type, :boolean}, {:required, false}, {:default, false}],
             return: [type: :enum, values: [:context, :response], default: :response, required: true]
           } == options
  end

  test "dispatch with no handler" do
    alias Protocol.DispatchNoHandler

    error = "No CommandHandler found for query: Cqrs.CommandTest.Protocol.DispatchNoHandler"

    assert_raise(DispatchError, error, fn ->
      %{name: "chris"}
      |> DispatchNoHandler.new()
      |> DispatchNoHandler.dispatch()
    end)
  end

  describe "dispatch" do
    alias Protocol.DispatchWithHandler

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

      assert %{reply_to: ["can't be blank"]} = Command.errors(context)
    end

    test "command requires reply_to option to be set to a valid Pid" do
      assert {:error, context} =
               %{name: "chris"}
               |> DispatchWithHandler.new()
               |> DispatchWithHandler.dispatch(reply_to: "lkajsdf")

      assert %{reply_to: ["is not a valid Pid"]} = Command.errors(context)
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

      assert %{} == Command.errors(context)
      assert "YO-HOHO" = Command.results(context)
      assert %{child: %{related: "value"}} = Command.private(context)
    end
  end

  describe "async dispatch" do
    alias Protocol.DispatchWithHandler

    test "is simple" do
      assert task =
               %{name: "chris"}
               |> DispatchWithHandler.new()
               |> DispatchWithHandler.dispatch_async(return: :context, reply_to: self())

      assert {:ok, context} = Task.await(task)

      assert %{child: %{related: "value"}} = Command.private(context)
      assert "YO-HOHO" = Command.results(context)
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

      assert %{generic: [:before_dispatch_error]} = Command.errors(context)
      assert {:error, :before_dispatch_error} == DispatchContext.get_last_pipeline(context)
    end

    test "simulate error in handle_authorize" do
      {:error, context} = dispatch(error_at: :handle_authorize)

      assert %{
               errors: [:handle_authorize_error],
               last_pipeline_step: :handle_authorize,
               private: %{child: %{related: "value"}}
             } = context

      assert %{generic: [:handle_authorize_error]} = Command.errors(context)
      assert {:error, :handle_authorize_error} == DispatchContext.get_last_pipeline(context)
    end

    test "simulate error in handle_dispatch" do
      {:error, context} = dispatch(error_at: :handle_dispatch)

      assert %{
               errors: [:handle_dispatch_error],
               last_pipeline_step: :handle_dispatch,
               private: %{child: %{related: "value"}}
             } = context

      assert %{generic: [:handle_dispatch_error]} = Command.errors(context)
      assert {:error, :handle_dispatch_error} == DispatchContext.get_last_pipeline(context)
    end

    defp dispatch(error_at: error_at) do
      opts = [error_at: error_at, return: :context, reply_to: self()]

      %{name: "chris"}
      |> DispatchWithHandler.new()
      |> DispatchWithHandler.dispatch(opts)
    end
  end

  describe "event derivation" do
    alias Cqrs.CommandTest.Events.NamespacedEventWithExtrasAndDrops
    alias Protocol.{CommandWithEventDerivations, DefaultEvent, EventWithExtras, EventWithDrops, EventWithExtrasAndDrops}

    test "event structs are created" do
      %{} = %DefaultEvent{}
      %{} = %EventWithExtras{}
      %{} = %EventWithExtrasAndDrops{}
      %{} = %NamespacedEventWithExtrasAndDrops{}
    end

    test "are created and returned from handler" do
      {:ok, events} =
        %{name: "chris"}
        |> CommandWithEventDerivations.new()
        |> CommandWithEventDerivations.dispatch()

      today = Date.utc_today()

      assert %{
               default_event: %DefaultEvent{dog: "maize", name: "chris"},
               event_with_drops: %EventWithDrops{name: "chris"},
               event_with_extras: %EventWithExtras{dog: "maize", name: "chris", date: ^today},
               event_with_extras_and_drops: %EventWithExtrasAndDrops{name: "chris", date: ^today},
               namespaced_event_with_extras_and_drops: %NamespacedEventWithExtrasAndDrops{name: "chris", date: ^today}
             } = events
    end
  end
end
