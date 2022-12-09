defmodule Blunt.Data.Factories.Values.MergePropsTest do
  use ExMachina
  use Blunt.Data.Factories
  use ExUnit.Case, async: true

  factory :one do
    defaults name: "chris", dog: "maize"
  end

  factory :two do
    prop :one_data, &build(:one, &1)
    merge_props(:one_data)
  end

  test "data is merged from one to two" do
    assert %{name: "chris", dog: "maize"} = results = build(:two)
    refute Map.has_key?(results, :one_data)
  end
end
