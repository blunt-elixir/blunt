defmodule Blunt.ContextTest do
  use ExUnit.Case, async: true

  alias Blunt.{DispatchContext, Query}
  alias Support.ContextTest.UsersContext
  alias Support.ContextTest.ReadModel.Person

  test "create_person functions are created" do
    assert [1, 2] == UsersContext.__info__(:functions) |> Keyword.get_values(:create_person)
  end

  test "can rename proxy functions" do
    assert [1, 2] == UsersContext.__info__(:functions) |> Keyword.get_values(:create_person2)
  end

  test "proxy functions can set option values" do
    assert {:ok, context} = UsersContext.create_person_with_custom_opts(%{name: "chris"}, return: :context)

    assert true == DispatchContext.get_option(context, :send_notification)
  end

  test "get_person proxy" do
    assert [0, 1, 2] == UsersContext.__info__(:functions) |> Keyword.get_values(:get_person)
  end

  test "get_person_query proxy" do
    assert [1, 2] == UsersContext.__info__(:functions) |> Keyword.get_values(:get_person_query)
  end

  test "get_person_query returns the ecto query without executing it" do
    assert {:ok, query} = UsersContext.get_person_query(%{id: UUID.uuid4()})
    assert %Ecto.Query{from: %{source: {"people", Person}}} = query
  end

  test "passing other values to the return option have no effect on the return value" do
    assert {:ok, query} = UsersContext.get_person_query(%{id: UUID.uuid4()}, return: :context)
    assert %Ecto.Query{from: %{source: {"people", Person}}} = query

    assert {:ok, query} = UsersContext.get_person_query(%{id: UUID.uuid4()}, return: :response)
    assert %Ecto.Query{from: %{source: {"people", Person}}} = query
  end

  test "get_person returns the person" do
    alias Support.ContextTest.ReadModel.Person

    assert {:ok, %{id: person_id}} = UsersContext.create_person(name: "chris")

    assert {:ok, %Person{id: ^person_id}} = UsersContext.get_person(id: person_id)

    assert {:ok, context} = UsersContext.get_person(%{id: person_id}, return: :context)

    assert %Person{id: ^person_id} = Query.results(context)
    assert %Ecto.Query{from: %{source: {"people", Person}}} = Query.query(context)
  end

  test "field_values option will supply query fields" do
    id = "07faaf1d-5890-4391-a6db-50e86c240965"
    assert {:ok, context} = UsersContext.get_known_user([], return: :context)
    assert %{id: ^id} = Query.filters(context)
  end
end
