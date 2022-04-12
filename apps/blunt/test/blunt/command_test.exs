defmodule Blunt.CommandTest do
  use ExUnit.Case, async: true

  alias Blunt.Message.Metadata
  alias Blunt.CommandTest.Protocol
  alias Blunt.{Command, DispatchContext}
  alias Blunt.DispatchStrategy.PipelineResolver

  test "command options" do
    alias Protocol.CommandOptions
    options = Metadata.options(CommandOptions)

    assert %{
             audit: [type: :boolean, required: false, default: true],
             debug: [type: :boolean, required: false, default: false],
             return: [type: :enum, values: [:context, :response], default: :response, required: false]
           } = options
  end

  describe "discarded data" do
    alias Protocol.DispatchWithPipeline

    test "field is defined" do
      assert {:discarded_data, :map, [required: false, internal: true]} =
               DispatchWithPipeline
               |> Metadata.fields()
               |> Enum.find(&match?({:discarded_data, _, _}, &1))
    end

    test "data is preserved" do
      attrs = %{name: "chris", poop: :yum}

      {:ok, command} = DispatchWithPipeline.new(attrs)

      assert %{discarded_data: %{"poop" => :yum}} = command

      assert {:ok, dispatch_context} = DispatchWithPipeline.dispatch(command, reply_to: self(), return: :context)

      assert %{discarded_data: %{"poop" => :yum}} = dispatch_context
    end
  end

  test "dispatch with no pipeline" do
    alias Protocol.DispatchNoPipeline

    error = "No Blunt.CommandHandler found for command: Blunt.CommandTest.Protocol.DispatchNoPipeline"

    assert_raise(PipelineResolver.Error, error, fn ->
      %{name: "chris"}
      |> DispatchNoPipeline.new()
      |> DispatchNoPipeline.dispatch()
    end)
  end

  describe "dispatch" do
    alias Protocol.DispatchWithPipeline

    test "options" do
      options = Metadata.options(DispatchWithPipeline)

      assert %{
               reply_to: [type: :pid, default: nil, required: true],
               return: [type: :enum, values: [:context, :response], default: :response, required: false],
               return_error: [type: :boolean, required: false, default: false]
             } = options
    end

    test "command requires reply_to option to be set" do
      assert {:error, context} =
               %{name: "chris"}
               |> DispatchWithPipeline.new()
               |> DispatchWithPipeline.dispatch()

      assert %{reply_to: ["can't be blank"]} = Command.errors(context)
    end

    test "command requires reply_to option to be set to a valid Pid" do
      assert {:error, context} =
               %{name: "chris"}
               |> DispatchWithPipeline.new()
               |> DispatchWithPipeline.dispatch(reply_to: "lkajsdf")

      assert %{reply_to: ["is not a valid Pid"]} = Command.errors(context)
    end

    test "returns handle_dispatch result by default" do
      assert {:ok, "YO-HOHO"} =
               %{name: "chris"}
               |> DispatchWithPipeline.new()
               |> DispatchWithPipeline.dispatch(reply_to: self())
    end

    test "returns context if selected in option" do
      assert {:ok, context} =
               %{name: "chris"}
               |> DispatchWithPipeline.new()
               |> DispatchWithPipeline.dispatch(return: :context, reply_to: self())

      assert %{} == Command.errors(context)
      assert "YO-HOHO" = Command.results(context)
    end
  end

  describe "async dispatch" do
    alias Protocol.DispatchWithPipeline

    test "is simple" do
      assert task =
               %{name: "chris"}
               |> DispatchWithPipeline.new()
               |> DispatchWithPipeline.dispatch_async(return: :context, reply_to: self())

      assert {:ok, context} = Task.await(task)

      assert "YO-HOHO" = Command.results(context)
    end
  end

  describe "dispatch error simulations" do
    alias Protocol.DispatchWithPipeline

    test "simulate error in handle_dispatch" do
      {:error, context} =
        %{name: "chris"}
        |> DispatchWithPipeline.new()
        |> DispatchWithPipeline.dispatch(return_error: true, return: :context, reply_to: self())

      assert %{
               errors: [:handle_dispatch_error],
               last_pipeline_step: :handle_dispatch
             } = context

      assert :handle_dispatch_error = Command.errors(context)
      assert {:error, :handle_dispatch_error} == DispatchContext.get_last_pipeline(context)
    end
  end

  describe "metadata" do
    alias Protocol.CommandWithMeta

    assert {:ok, context} = CommandWithMeta.new() |> CommandWithMeta.dispatch(return: :context)

    metadata = Command.get_metadata(context, :auth)

    refute is_nil(metadata)

    assert [:owner, :collaborator] == metadata[:user_roles]
    assert [:broker, :carrier] == metadata[:account_types]
  end

  describe "ecto multi option" do
    defmodule MultiCommand do
      use Blunt.Command
      option :multi, :ecto_multi, required: true
      option :reply_to, :pid, required: true
    end

    defmodule MultiCommandHandler do
      use Blunt.CommandHandler

      def handle_dispatch(_command, context) do
        reply_to = Blunt.DispatchContext.get_option(context, :reply_to)
        multi = Blunt.DispatchContext.get_option(context, :multi)
        send(reply_to, {:multi, multi})
      end
    end

    test "can pass option" do
      person_changeset = Support.ReadModel.Person.changeset(%{id: UUID.uuid4(), name: "chris"})
      multi = Ecto.Multi.new() |> Ecto.Multi.insert(:thing, person_changeset)

      MultiCommand.new()
      |> MultiCommand.dispatch(reply_to: self(), multi: multi)

      assert_receive {:multi, ^multi}
    end
  end
end
