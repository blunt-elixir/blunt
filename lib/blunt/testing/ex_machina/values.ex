if Code.ensure_loaded?(ExMachina) and Code.ensure_loaded?(Faker) do
  defmodule Blunt.Testing.ExMachina.Values do
    alias Blunt.Testing.ExMachina.Factory

    defmodule Constant do
      @moduledoc false
      @derive Inspect
      defstruct [:field, :value]
    end

    @doc """
    The `field` of the factory source data will be assigned
    to the value
    """
    defmacro const(field, value) do
      quote do
        %Constant{field: unquote(field), value: unquote(value)}
      end
    end

    defmodule Lazy do
      @moduledoc false
      @derive Inspect
      defstruct [:field, :factory]
    end

    @doc """
    If the `field` is not supplied to the factory,
    the given `message` will be dispatched with the returned
    data to be put into the factory source data with the `field` key.
    """
    defmacro lazy(field, message, values \\ []) do
      quote do
        %Lazy{
          field: unquote(field),
          factory: %Factory{
            dispatch?: true,
            message: unquote(message),
            values: unquote(values)
          }
        }
      end
    end

    defmodule Prop do
      @moduledoc false
      @derive Inspect
      defstruct [:field, :value_path_or_func]
    end

    @doc """
    The `field` of the factory source data will be assigned
    to the value of `value_path_or_func` in the factory source
    """
    defmacro prop(field, value_path_or_func) do
      quote do
        %Prop{field: unquote(field), value_path_or_func: unquote(value_path_or_func)}
      end
    end
  end
end
