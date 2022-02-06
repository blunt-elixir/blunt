defmodule Cqrs.QueryTest do
  use ExUnit.Case, async: true

  alias Cqrs.Query
  alias Cqrs.QueryTest.Protocol

  describe "basics" do
    alias Protocol.BasicQuery
    alias Cqrs.DispatchStrategy.HandlerProvider.Error

    test "predefined options" do
      options = BasicQuery.__options__() |> Enum.into(%{})

      assert %{
               allow_nil_filters: [type: :boolean, default: false, required: true],
               execute: [type: :boolean, default: true, required: true],
               preload: [type: {:array, :any}, default: [], required: true],
               return: [
                 type: :enum,
                 values: [:context, :response],
                 default: :response,
                 required: true
               ]
             } = options
    end

    test "no predefined bindings" do
      assert [] == BasicQuery.__bindings__()
    end

    test "no handler" do
      error = "No QueryHandler found for query: Cqrs.QueryTest.Protocol.BasicQuery"

      assert_raise(Error, error, fn ->
        BasicQuery.new()
        |> BasicQuery.dispatch(return: :context)
      end)
    end
  end

  describe "dispatch" do
    alias Protocol.{CreatePerson, GetPerson}

    defp create_person(name) do
      %{name: name}
      |> CreatePerson.new()
      |> CreatePerson.dispatch()
    end

    setup do
      assert {:ok, %{id: chris_id}} = create_person("chris")
      assert {:ok, %{id: sarah_id}} = create_person("sarah")

      %{
        chris_id: chris_id,
        sarah_id: sarah_id
      }
    end

    test "with id filter", %{chris_id: chris_id} do
      assert {:ok, %{id: ^chris_id, name: "chris"}} =
               %{id: chris_id}
               |> GetPerson.new()
               |> GetPerson.dispatch()
    end

    test "async", %{chris_id: chris_id} do
      task =
        %{id: chris_id}
        |> GetPerson.new()
        |> GetPerson.dispatch_async()

      assert {:ok, %{id: ^chris_id, name: "chris"}} = Task.await(task)
    end

    test "context holds some good data", %{sarah_id: sarah_id} do
      assert {:ok, context} =
               %{id: sarah_id, name: "sarah"}
               |> GetPerson.new()
               |> GetPerson.dispatch(return: :context)

      assert %{id: ^sarah_id, name: "sarah"} = Query.filters(context)
      assert %Ecto.Query{} = Query.query(context)
      assert %{id: ^sarah_id, name: "sarah"} = Query.results(context)
    end
  end
end
