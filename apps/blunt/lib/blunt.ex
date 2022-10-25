defmodule Blunt do
  defmacro __using__(_opts) do
    quote do
      import Blunt, only: :macros
    end
  end

  defmacro defcommand(opts \\ [], do: body) do
    quote do
      use Blunt.Command, unquote(opts)
      unquote(body)
    end
  end

  defmacro defquery(opts \\ [], do: body) do
    quote do
      use Blunt.Query, unquote(opts)
      unquote(body)
    end
  end
end
