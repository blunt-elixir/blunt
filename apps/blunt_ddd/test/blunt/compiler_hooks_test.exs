defmodule BluntDdd.Test.Blunt.CompilerHooksTest do
  use ExUnit.Case

  alias Blunt.Message.Metadata

  describe "domain events" do
    defmodule Event do
      use Blunt.DomainEvent,
        config: [
          compiler_hooks: [domain_event: {Blunt.Test.CompilerHooks, :add_user_id_field}]
        ]
    end

    test "have user_id field" do
      assert Event
             |> Metadata.field_names()
             |> Enum.member?(:user_id)
    end
  end

  describe "value objects" do
    defmodule ValueObject do
      use Blunt.ValueObject,
        config: [
          compiler_hooks: [value_object: {Blunt.Test.CompilerHooks, :add_user_id_field}]
        ]
    end

    test "have user_id field" do
      assert ValueObject
             |> Metadata.field_names()
             |> Enum.member?(:user_id)
    end
  end

  describe "entities" do
    defmodule Entity do
      use Blunt.Entity,
        config: [
          compiler_hooks: [entity: {Blunt.Test.CompilerHooks, :add_user_id_field}]
        ]
    end

    test "have user_id field" do
      assert Entity
             |> Metadata.field_names()
             |> Enum.member?(:user_id)
    end
  end

  describe "states" do
    defmodule State do
      use Blunt.State,
        config: [
          compiler_hooks: [state: {Blunt.Test.CompilerHooks, :add_user_id_field}]
        ]
    end

    test "do not have user_id field" do
      refute State
             |> Metadata.field_names()
             |> Enum.member?(:user_id)
    end
  end
end
