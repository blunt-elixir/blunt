defmodule Blunt.Ddd do
  defmacro __using__(_opts) do
    quote do
      import Blunt.Ddd, only: :macros
    end
  end

  defmacro defstate(do: body) do
    quote do
      use Blunt.State
      unquote(body)
    end
  end

  defmacro defcontext(do: body) do
    quote do
      use Blunt.Context
      unquote(body)
    end
  end

  defmacro defevent(opts \\ [], do: body) do
    quote do
      use Blunt.DomainEvent, unquote(opts)
      unquote(body)
    end
  end

  defmacro defvalue(opts \\ [], do: body) do
    quote do
      use Blunt.ValueObject, unquote(opts)
      unquote(body)
    end
  end

  defmacro defentity(opts \\ [], do: body) do
    quote do
      use Blunt.Entity, unquote(opts)
      unquote(body)
    end
  end
end
