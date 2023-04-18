defmodule Blunt.Data.Factories.FactoryTest do
  use ExMachina
  use Blunt.Data.Factories
  use ExUnit.Case, async: true

  alias Blunt.Data.Factories.ValueError

  factory :error_env do
    prop :name, fn %{name: name} -> name end
  end

  test "error indicates what prop failed evaluation" do
    exception =
      assert_raise(ValueError, fn ->
        build(:error_env)
      end)

    assert ValueError.message(exception) == """

           factory: error_env
           prop: :name

           %FunctionClauseError{module: Blunt.Data.Factories.FactoryTest, function: :\"-error_env_factory/1-fun-0-\", arity: 1, kind: nil, args: nil, clauses: nil}
           """
  end
end
