defmodule Blunt.Absinthe.Relay do
  defmodule Error do
    defexception [:message]
  end

  alias Blunt.Absinthe.Message
  alias Blunt.Absinthe.Relay.{Connection, ConnectionField}

  defmacro __using__(_opts) do
    quote do
      Module.register_attribute(__MODULE__, :queries, accumulate: true)

      import Blunt.Absinthe.Relay, only: :macros

      @after_compile Blunt.Absinthe.Relay
    end
  end

  defmacro define_connection(node_type, opts \\ []) do
    total_count =
      if opts[:total_count] do
        Connection.generate_total_count_field()
      end

    body = opts[:do]

    connection =
      quote do
        connection node_type: unquote(node_type) do
          unquote(total_count)
          unquote(body)

          edge do
          end
        end
      end

    Module.eval_quoted(__CALLER__, connection)
  end

  defmacro derive_connection(query_module, return_type, opts) do
    opts = Macro.escape(opts)
    field = quote do: ConnectionField.generate(unquote(query_module), unquote(return_type), unquote(opts))
    field = Module.eval_quoted(__CALLER__, field)

    quote do
      @queries unquote(query_module)
      unquote(field)
    end
  end

  defmacro __after_compile__(_env, _bytecode) do
    quote do
      Enum.each(@queries, &Message.validate!(:query, &1))
      # Enum.each(@mutations, &Message.validate!(:command, &1))
    end
  end
end
