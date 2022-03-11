defmodule Blunt.QueryTest do
  use ExUnit.Case, async: true

  alias Blunt.Query
  alias Blunt.Message.Metadata
  alias Blunt.QueryTest.Protocol

  describe "basics" do
    alias Protocol.BasicQuery
    alias Blunt.DispatchStrategy.PipelineResolver

    test "predefined options" do
      options = Metadata.options(BasicQuery)

      assert %{
               allow_nil_filters: [type: :boolean, default: false, required: false],
               preload: [type: {:array, :any}, default: [], required: false],
               return: [
                 type: :enum,
                 values: [:context, :response, :query, :query_context],
                 default: :response,
                 required: false
               ]
             } = options
    end

    test "no predefined bindings" do
      assert [] == Metadata.get(BasicQuery, :bindings)
    end

    test "no pipeline" do
      error = "No Blunt.QueryPipeline found for query: Blunt.QueryTest.Protocol.BasicQuery"

      assert_raise(PipelineResolver.Error, error, fn ->
        BasicQuery.new()
        |> BasicQuery.dispatch(return: :context)
      end)
    end
  end

  describe "dispatch" do
    alias Protocol.{CreatePerson, GetPerson}

    defp create_person(name) do
      assert {:ok, person} =
               %{name: name}
               |> CreatePerson.new()
               |> CreatePerson.dispatch()

      person
    end

    setup do
      assert %{id: chris_id} = create_person("chris")
      assert %{id: sarah_id} = create_person("sarah")

      %{chris_id: chris_id, sarah_id: sarah_id}
    end

    test "can create query without executing it", %{chris_id: chris_id} do
      assert {:ok, %Ecto.Query{}} =
               %{id: chris_id}
               |> GetPerson.new()
               |> GetPerson.dispatch(return: :query)
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
      alias Blunt.QueryTest.ReadModel.Person

      assert {:ok, context} =
               %{id: sarah_id, name: "sarah"}
               |> GetPerson.new()
               |> GetPerson.dispatch(return: :context)

      assert [person: Person] = Query.bindings(context)
      assert %{id: ^sarah_id, name: "sarah"} = Query.filters(context)
      assert %Person{id: ^sarah_id, name: "sarah"} = Query.results(context)
      assert %Ecto.Query{from: %{source: {"people", Person}}} = Query.query(context)
    end
  end

  describe "preload option" do
    defmodule PreloadQuery do
      use Blunt.Query

      option :preload, {:array, :any}, default: [:name]
    end

    test "set default value" do
      assert %{preload: [type: {:array, :any}, required: false, default: [:name]]} = Metadata.options(PreloadQuery)
    end
  end
end
