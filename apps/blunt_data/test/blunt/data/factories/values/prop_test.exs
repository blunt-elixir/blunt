defmodule Blunt.Data.Factories.Values.PropTest do
  use ExMachina
  use Blunt.Data.Factories
  use ExUnit.Case, async: true

  factory :one do
    defaults name: "chris", dog: "maize"
  end

  factory :two do
    merge_prop(:one_data, &build(:one, &1))
    merge_prop(:prefixed_data, &build(:one, &1), prefix: "one")
  end

  test "data is merged from one to two" do
    assert %{name: "chris", dog: "maize", one_name: "chris", one_dog: "maize"} = results = build(:two)
    refute Map.has_key?(results, :one_data)
    refute Map.has_key?(results, :prefixed_data)
  end
end
