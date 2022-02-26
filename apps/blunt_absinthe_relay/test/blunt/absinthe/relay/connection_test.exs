defmodule Blunt.Absinthe.Relay.ConnectionTest do
  use ExUnit.Case, async: false

  alias Blunt.Absinthe.Relay.Test.{CreatePeople, Schema}

  setup_all do
    peeps = [
      %{id: UUID.uuid4(), name: "chris"},
      %{id: UUID.uuid4(), name: "chris", gender: :male},
      %{id: UUID.uuid4(), name: "chris", gender: :male},
      %{id: UUID.uuid4(), name: "sarah", gender: :female},
      %{id: UUID.uuid4(), name: "sarah", gender: :female},
      %{id: UUID.uuid4(), name: "luke", gender: :not_sure},
      %{id: UUID.uuid4(), name: "michael", gender: :not_sure}
    ]

    assert {:ok, _people} =
             %{peeps: peeps}
             |> CreatePeople.new()
             |> CreatePeople.dispatch()

    %{
      query: """
      query list($name: String, $gender: Gender, $after: String){
        listPeople(first: 2, after: $after, name: $name, gender: $gender){
          pageInfo {
            hasNextPage
          }
          edges {
            node {
              id
              name
              gender
            }
          }
        }
      }
      """
    }
  end

  @doc """
  The Ecto Etso adapter does not support windowing functions or counting via repo.aggregate.

  This stops me from testing totalCount on the connection and fetching next pages.

  This is livable, but I should really just configure postgres. I just don't want to now.
  """

  test "totalCount is present on the connection" do
    # Etso won't do the count aggregate function. Maybe I'll switch to postgres. This is a downer.
    assert %{fields: %{total_count: _}} = Absinthe.Schema.lookup_type(Schema, "PersonConnection")
  end

  test "searching for chris should return two pages", %{query: query} do
    assert {:ok, %{data: %{"listPeople" => %{"pageInfo" => page_info, "edges" => edges}}}} =
             Absinthe.run(query, Schema, variables: %{"name" => "chris"})

    assert length(edges) == 2
    assert %{"hasNextPage" => true} = page_info
  end

  test "searching for gender NOT_SURE should return two pages", %{query: query} do
    assert {:ok, %{data: %{"listPeople" => %{"pageInfo" => page_info, "edges" => edges}}}} =
             Absinthe.run(query, Schema, variables: %{"gender" => "NOT_SURE"})

    assert length(edges) == 2
    assert %{"hasNextPage" => true} = page_info

    assert edges
           |> Enum.map(&get_in(&1, ["node", "name"]))
           |> Enum.all?(fn name -> name in ["chris", "luke", "michael"] end)
  end
end
