defmodule BluntCommandedDialectTest do
  use ExUnit.Case
  doctest BluntCommandedDialect

  test "greets the world" do
    assert BluntCommandedDialect.hello() == :world
  end
end
