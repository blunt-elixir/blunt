defmodule Blunt.Message.CompilerHooksTest do
  use ExUnit.Case

  alias Blunt.Message.Metadata

  describe "plain messages" do
    defmodule Message do
      use Blunt.Message,
        config: [
          compiler_hooks: [message: {Blunt.Test.CompilerHooks, :add_user_id_field}]
        ]
    end

    test "do not have user_id field" do
      refute Message
             |> Metadata.field_names()
             |> Enum.member?(:user_id)
    end
  end

  describe "commands" do
    defmodule Command do
      use Blunt.Command,
        config: [
          compiler_hooks: [command: {Blunt.Test.CompilerHooks, :add_user_id_field}]
        ]
    end

    test "have user_id field" do
      assert Command
             |> Metadata.field_names()
             |> Enum.member?(:user_id)
    end
  end

  describe "queries" do
    defmodule Query do
      use Blunt.Query,
        config: [
          compiler_hooks: [query: {Blunt.Test.CompilerHooks, :add_user_id_field}]
        ]
    end

    test "have user_id field" do
      assert Query
             |> Metadata.field_names()
             |> Enum.member?(:user_id)
    end
  end
end
