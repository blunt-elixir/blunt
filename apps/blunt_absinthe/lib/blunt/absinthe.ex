defmodule Blunt.Absinthe do
  alias Blunt.Absinthe.{Message, Mutation, Query}
  alias Blunt.Absinthe.Enum, as: AbsintheEnum

  defmodule Error do
    defexception [:message]
  end

  defmacro __using__(_opts) do
    quote do
      Module.register_attribute(__MODULE__, :queries, accumulate: true)
      Module.register_attribute(__MODULE__, :mutations, accumulate: true)

      # use Absinthe.Schema
      import Blunt.Absinthe, only: :macros

      @after_compile Blunt.Absinthe
    end
  end

  defmacro derive_enum(enum_name, {enum_source_module, field_name}) do
    enum = quote do: AbsintheEnum.generate_type(unquote(enum_name), {unquote(enum_source_module), unquote(field_name)})
    Module.eval_quoted(__CALLER__, enum)
  end

  @spec derive_query(atom(), any(), keyword()) :: term()
  defmacro derive_query(query_module, return_type, opts \\ []) do
    opts = Macro.escape(opts)
    return_type = Macro.escape(return_type)

    field = quote do: Query.generate_field(unquote(query_module), unquote(return_type), unquote(opts))
    field = Module.eval_quoted(__CALLER__, field)

    quote do
      @queries unquote(query_module)
      unquote(field)
    end
  end

  @spec derive_mutation(atom(), any(), keyword()) :: term()
  defmacro derive_mutation(command_module, return_type, opts \\ []) do
    opts = Macro.escape(opts)
    return_type = Macro.escape(return_type)

    field = quote do: Mutation.generate_field(unquote(command_module), unquote(return_type), unquote(opts))
    field = Module.eval_quoted(__CALLER__, field)

    quote do
      @mutations unquote(command_module)
      unquote(field)
    end
  end

  defmacro __after_compile__(_env, _bytecode) do
    quote do
      Enum.each(@queries, &Message.validate!(:query, &1))
      Enum.each(@mutations, &Message.validate!(:command, &1))
    end
  end
end
