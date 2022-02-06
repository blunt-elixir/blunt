defmodule Cqrs do
  defmacro __using__(_opts) do
    quote do
      import Cqrs, only: :macros
    end
  end

  defmacro defcommand(opts \\ [], do: body) do
    quote do
      use Cqrs.Command, unquote(opts)
      unquote(body)
    end
  end

  defmacro defevent(opts \\ [], do: body) do
    quote do
      use Cqrs.DomainEvent, unquote(opts)
      unquote(body)
    end
  end

  defmacro defquery(opts \\ [], do: body) do
    quote do
      use Cqrs.Query, unquote(opts)
      unquote(body)
    end
  end

  defmacro defvalue_object(opts \\ [], do: body) do
    quote do
      use Cqrs.ValueObject, unquote(opts)
      unquote(body)
    end
  end
end
