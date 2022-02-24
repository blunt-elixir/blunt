defmodule Blunt.Testing.ExMachina.Value do
  defmodule ConstantValue do
    @moduledoc """
    The `field` of the factory source data will be assigned
    to the value
    """
    defstruct [:field, :value]
  end

  defmodule PropValue do
    @moduledoc """
    The `field` of the factory source data will be assigned
    to the value of `value_path` in the factory source
    """
    defstruct [:field, :value_path]
  end

  defmodule LazyValue do
    @moduledoc """
    If the `property` is not supplied to the factory,
    the given `message` will be dispatched with the returned
    data to be put into the factory source data with the `field` key.
    """
    defstruct [:property, :message, :factory_opts]
  end

  defmacro const(field, value) do
    quote do
      %ConstantValue{field: unquote(field), value: unquote(value)}
    end
  end

  defmacro lazy(property, message, value) do
    quote do
      %LazyValue{property: unquote(property), message: unquote(message), value: unquote(value)}
    end
  end

  defmacro prop(field, value_path) do
    quote do
      %PropValue{field: unquote(field), value_path: unquote(value_path)}
    end
  end
end
