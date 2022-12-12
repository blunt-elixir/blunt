defmodule Blunt.Data.Factories.FactoryTest do
  use ExMachina
  use Blunt.Data.Factories
  use ExUnit.Case, async: true

  alias Blunt.Data.Factories.ValueError

  factory :error_env do
    prop :name, fn %{name: name} -> name end
  end

  test "error indicates what prop failed evaluatation" do
    exception =
      assert_raise(ValueError, fn ->
        build(:error_env)
      end)

    """
    factory: error_env
    prop: :name

    %FunctionClauseError{module: Blunt.Data.Factories.FactoryTest, function: :\"-error_env_factory/1-fun-0-\", arity: 1, kind: nil, args: nil, clauses: nil}
    """ == ValueError.message(exception)
  end
end
